(() => {
    const editor = document.getElementById('note-editor');
    if (!editor) {
        return;
    }

    let currentRawText = '';
    let macros = {};
    let environments = {};
    let suppressNotification = false;

    const defaultMacros = {
        '\\RR': '\\mathbb{R}',
        '\\QQ': '\\mathbb{Q}',
        '\\ZZ': '\\mathbb{Z}',
        '\\NN': '\\mathbb{N}',
        '\\CC': '\\mathbb{C}',
        '\\EE': '\\mathbb{E}',
        '\\Var': '\\operatorname{Var}',
        '\\Cov': '\\operatorname{Cov}',
        '\\grad': '\\nabla'
    };

    const defaultEnvironments = {
        lemma: { title: 'Lemma' },
        theorem: { title: 'Theorem' },
        proposition: { title: 'Proposition' },
        corollary: { title: 'Corollary' },
        definition: { title: 'Definition' }
    };

    const delimiters = [
        { left: '$$', right: '$$', display: true },
        { left: '\\[', right: '\\]', display: true },
        { left: '\\(', right: '\\)', display: false },
        { left: '$', right: '$', display: false }
    ];

    function initialize() {
        editor.addEventListener('input', handleInput);
        editor.addEventListener('paste', handlePaste);
        editor.addEventListener('drop', event => event.preventDefault());
        editor.addEventListener('keydown', event => {
            if (event.key === 'Tab') {
                event.preventDefault();
                insertText('    ');
            }
        });
        editor.addEventListener('dblclick', handleDoubleClick);

        ensureBaseLine();
        renderContent({ preserveSelection: false });
    }

    function ensureBaseLine() {
        if (editor.childNodes.length === 0) {
            const div = document.createElement('div');
            div.appendChild(document.createElement('br'));
            editor.appendChild(div);
        }
    }

    function handleInput() {
        renderContent();
    }

    function handlePaste(event) {
        event.preventDefault();
        const text = (event.clipboardData || window.clipboardData).getData('text/plain');
        insertText(text);
    }

    function handleDoubleClick(event) {
        const target = event.target.closest('.math-fragment');
        if (!target) {
            return;
        }
        const latex = target.dataset.latex || '';
        const textNode = document.createTextNode(latex);
        target.replaceWith(textNode);
        placeCaretAfter(textNode, latex.length);
        renderContent();
    }

    function insertText(text) {
        const selection = window.getSelection();
        if (!selection || selection.rangeCount === 0) {
            return;
        }
        const range = selection.getRangeAt(0);
        range.deleteContents();
        range.insertNode(document.createTextNode(text));
        range.collapse(false);
        selection.removeAllRanges();
        selection.addRange(range);
        renderContent();
    }

    function handleThemeChange(mode) {
        document.body.classList.toggle('dark', mode === 'dark');
    }

    function handleInputFromHost(text) {
        suppressNotification = true;
        populateEditor(text);
        renderContent({ preserveSelection: false });
        currentRawText = text;
        suppressNotification = false;
    }

    function populateEditor(text) {
        editor.innerHTML = '';
        const lines = text.split(/\r?\n/);
        lines.forEach((line, index) => {
            const div = document.createElement('div');
            if (line.length === 0) {
                div.appendChild(document.createElement('br'));
            } else {
                div.appendChild(document.createTextNode(line));
            }
            editor.appendChild(div);
            if (index === lines.length - 1 && line.length === 0) {
                div.appendChild(document.createElement('br'));
            }
        });
        ensureBaseLine();
    }

    function renderContent({ preserveSelection = true } = {}) {
        const selectionSnapshot = preserveSelection ? captureSelection() : null;
        revertMathFragments(editor);
        const rawText = extractRawText(editor);
        updateDefinitions(rawText);
        typesetMathInEditor();
        if (selectionSnapshot) {
            restoreSelection(selectionSnapshot);
        }
        notifyHostIfNeeded(rawText);
    }

    function captureSelection() {
        const selection = window.getSelection();
        if (!selection || selection.rangeCount === 0) {
            return null;
        }
        const range = selection.getRangeAt(0);
        const cloneStart = range.cloneRange();
        cloneStart.selectNodeContents(editor);
        cloneStart.setEnd(range.startContainer, range.startOffset);
        const startFragment = cloneStart.cloneContents();
        const startOffset = computeRawLength(startFragment);

        let endOffset = startOffset;
        if (!selection.isCollapsed) {
            const cloneEnd = range.cloneRange();
            cloneEnd.selectNodeContents(editor);
            cloneEnd.setEnd(range.endContainer, range.endOffset);
            const endFragment = cloneEnd.cloneContents();
            endOffset = computeRawLength(endFragment);
        }

        return { start: startOffset, end: endOffset };
    }

    function restoreSelection(snapshot) {
        if (!snapshot) {
            return;
        }
        const segments = collectSegments(editor);
        const startPosition = locatePosition(segments, snapshot.start);
        const endPosition = locatePosition(segments, snapshot.end);
        if (!startPosition || !endPosition) {
            placeCaretAtEnd();
            return;
        }
        const range = document.createRange();
        range.setStart(startPosition.node, startPosition.offset);
        range.setEnd(endPosition.node, endPosition.offset);
        const selection = window.getSelection();
        selection.removeAllRanges();
        selection.addRange(range);
    }

    function placeCaretAfter(node, offset) {
        const range = document.createRange();
        range.setStart(node, offset);
        range.setEnd(node, offset);
        const selection = window.getSelection();
        selection.removeAllRanges();
        selection.addRange(range);
    }

    function placeCaretAtEnd() {
        const range = document.createRange();
        range.selectNodeContents(editor);
        range.collapse(false);
        const selection = window.getSelection();
        selection.removeAllRanges();
        selection.addRange(range);
    }

    function revertMathFragments(root) {
        const fragments = root.querySelectorAll('.math-fragment');
        fragments.forEach(fragment => {
            const latex = fragment.dataset.latex || '';
            const textNode = document.createTextNode(latex);
            fragment.replaceWith(textNode);
        });
    }

    function typesetMathInEditor() {
        if (!window.katex) {
            return;
        }
        const walker = document.createTreeWalker(editor, NodeFilter.SHOW_TEXT, null);
        const nodes = [];
        let current;
        while ((current = walker.nextNode())) {
            if (!current.textContent || current.textContent.trim().length === 0) {
                continue;
            }
            if (current.parentElement && current.parentElement.classList.contains('math-fragment')) {
                continue;
            }
            nodes.push(current);
        }

        nodes.forEach(node => {
            const fragment = transformTextNode(node);
            if (fragment) {
                node.replaceWith(fragment);
            }
        });
    }

    function transformTextNode(node) {
        const text = node.textContent || '';
        const segments = extractSegments(text);
        if (!segments.some(segment => segment.type === 'math')) {
            return null;
        }
        const fragment = document.createDocumentFragment();
        segments.forEach(segment => {
            if (segment.type === 'text') {
                fragment.appendChild(document.createTextNode(segment.value));
                return;
            }

            const mathContainer = document.createElement(segment.display ? 'div' : 'span');
            mathContainer.classList.add('math-fragment');
            mathContainer.dataset.latex = segment.raw;
            if (segment.display) {
                mathContainer.classList.add('math-display');
            } else {
                mathContainer.classList.add('math-inline');
            }

            const latex = applyEnvironmentTransforms(segment.content);
            try {
                window.katex.render(latex, mathContainer, {
                    displayMode: segment.display,
                    throwOnError: false,
                    macros
                });
            } catch (error) {
                mathContainer.classList.add('math-error');
                mathContainer.textContent = segment.raw;
            }
            fragment.appendChild(mathContainer);
        });
        return fragment;
    }

    function extractSegments(text) {
        const segments = [];
        let index = 0;
        while (index < text.length) {
            const match = findNextDelimiter(text, index);
            if (!match) {
                segments.push({ type: 'text', value: text.slice(index) });
                break;
            }

            if (match.index > index) {
                segments.push({ type: 'text', value: text.slice(index, match.index) });
            }

            const start = match.index + match.delimiter.left.length;
            const end = findClosing(text, start, match.delimiter.right);
            if (end === -1) {
                segments.push({ type: 'text', value: text.slice(match.index) });
                break;
            }

            const raw = text.slice(match.index, end + match.delimiter.right.length);
            const content = text.slice(start, end);
            segments.push({
                type: 'math',
                content,
                raw,
                display: match.delimiter.display
            });
            index = end + match.delimiter.right.length;
        }
        return segments;
    }

    function findNextDelimiter(text, startIndex) {
        let closest = null;
        delimiters.forEach(delimiter => {
            let position = text.indexOf(delimiter.left, startIndex);
            while (position !== -1 && isEscaped(text, position)) {
                position = text.indexOf(delimiter.left, position + delimiter.left.length);
            }
            if (position !== -1 && (closest === null || position < closest.index)) {
                closest = { index: position, delimiter };
            }
        });
        return closest;
    }

    function findClosing(text, startIndex, closing) {
        let position = startIndex;
        while (position < text.length) {
            const candidate = text.indexOf(closing, position);
            if (candidate === -1) {
                return -1;
            }
            if (!isEscaped(text, candidate)) {
                return candidate;
            }
            position = candidate + closing.length;
        }
        return -1;
    }

    function isEscaped(text, index) {
        let slashCount = 0;
        let i = index - 1;
        while (i >= 0 && text[i] === '\\') {
            slashCount += 1;
            i -= 1;
        }
        return slashCount % 2 === 1;
    }

    function updateDefinitions(rawText) {
        macros = { ...defaultMacros };
        environments = { ...defaultEnvironments };

        const macroRegex = /\\newcommand\s*\{\\([a-zA-Z@]+)\}(?:\[(\d+)\])?\s*\{([\s\S]*?)\}/g;
        rawText.replace(macroRegex, (_, name, _argCount, definition) => {
            macros[`\\${name}`] = definition;
            return '';
        });

        const declareRegex = /\\DeclareMathOperator\s*\{\\([a-zA-Z@]+)\}\s*\{([\s\S]*?)\}/g;
        rawText.replace(declareRegex, (_, name, body) => {
            macros[`\\${name}`] = `\\operatorname{${body}}`;
            return '';
        });

        const environmentRegex = /\\newenvironment\s*\{([a-zA-Z*@]+)\}(?:\[(\d+)\])?\s*\{([\s\S]*?)\}\s*\{([\s\S]*?)\}/g;
        rawText.replace(environmentRegex, (_, name, argCount, begin, end) => {
            environments[name] = {
                begin,
                end,
                argCount: argCount ? parseInt(argCount, 10) : 0
            };
            return '';
        });
    }

    function applyEnvironmentTransforms(latex) {
        const pattern = /\\begin\{([a-zA-Z*@]+)\}([\s\S]*?)\\end\{\1\}/g;
        return latex.replace(pattern, (_, name, body) => renderEnvironment(name, body));
    }

    function renderEnvironment(name, body) {
        const definition = environments[name];
        if (!definition) {
            return `\\begin{${name}}${body}\\end{${name}}`;
        }

        if (definition.title) {
            const label = definition.title;
            const inner = applyEnvironmentTransforms(body.trim());
            return `\\boxed{\\textbf{${label}.}\\quad ${inner}}`;
        }

        let remainder = body;
        const args = [];
        if (definition.argCount && definition.argCount > 0) {
            for (let i = 0; i < definition.argCount; i += 1) {
                remainder = remainder.trimStart();
                if (!remainder.startsWith('{')) {
                    break;
                }
                const extracted = extractBalanced(remainder);
                if (!extracted) {
                    break;
                }
                args.push(extracted.content);
                remainder = remainder.slice(extracted.length);
            }
        }

        let begin = definition.begin;
        let end = definition.end;
        args.forEach((arg, index) => {
            const token = new RegExp(`#${index + 1}`, 'g');
            begin = begin.replace(token, arg);
            end = end.replace(token, arg);
        });

        const inner = applyEnvironmentTransforms(remainder);
        return `${begin}${inner}${end}`;
    }

    function extractBalanced(text) {
        if (!text.startsWith('{')) {
            return null;
        }
        let depth = 0;
        for (let i = 0; i < text.length; i += 1) {
            const char = text[i];
            if (char === '{') {
                depth += 1;
            } else if (char === '}') {
                depth -= 1;
                if (depth === 0) {
                    return {
                        content: text.slice(1, i),
                        length: i + 1
                    };
                }
            }
        }
        return null;
    }

    function extractRawText(root) {
        const segments = collectSegments(root);
        return segments.map(segment => segment.value).join('');
    }

    function collectSegments(root) {
        const segments = [];
        const children = Array.from(root.childNodes);
        children.forEach((child, index) => {
            appendSegments(child, segments);
            if (child.nodeName === 'DIV' && index < children.length - 1) {
                segments.push({ type: 'newline', node: child, value: '\n', length: 1 });
            }
        });
        if (segments.length === 0) {
            segments.push({ type: 'text', node: root, value: '', length: 0 });
        }
        return segments;
    }

    function appendSegments(node, segments) {
        if (node.nodeType === Node.TEXT_NODE) {
            if (node.textContent && node.textContent.length > 0) {
                segments.push({ type: 'text', node, value: node.textContent, length: node.textContent.length });
            }
            return;
        }
        if (node.nodeType !== Node.ELEMENT_NODE) {
            return;
        }
        if (node.classList.contains('math-fragment')) {
            const latex = node.dataset.latex || '';
            segments.push({ type: 'math', node, value: latex, length: latex.length });
            return;
        }
        if (node.nodeName === 'BR') {
            segments.push({ type: 'newline', node, value: '\n', length: 1 });
            return;
        }
        const children = Array.from(node.childNodes);
        children.forEach(child => appendSegments(child, segments));
    }

    function locatePosition(segments, offset) {
        let remaining = offset;
        for (const segment of segments) {
            const length = segment.length ?? segment.value.length;
            if (remaining > length) {
                remaining -= length;
                continue;
            }
            if (segment.type === 'text') {
                return { node: segment.node, offset: remaining };
            }
            if (segment.type === 'math') {
                const parent = segment.node.parentNode || editor;
                const index = Array.prototype.indexOf.call(parent.childNodes, segment.node);
                return { node: parent, offset: remaining === 0 ? index : index + 1 };
            }
            if (segment.type === 'newline') {
                const parent = segment.node.parentNode || editor;
                const index = Array.prototype.indexOf.call(parent.childNodes, segment.node);
                return { node: parent, offset: index + 1 };
            }
        }
        const parent = editor;
        return { node: parent, offset: parent.childNodes.length };
    }

    function computeRawLength(fragment) {
        let total = 0;
        fragment.childNodes.forEach(child => {
            total += nodeRawLength(child);
        });
        return total;
    }

    function nodeRawLength(node) {
        if (node.nodeType === Node.TEXT_NODE) {
            return node.textContent.length;
        }
        if (node.nodeType !== Node.ELEMENT_NODE) {
            return 0;
        }
        if (node.classList.contains('math-fragment')) {
            const latex = node.dataset.latex || '';
            return latex.length;
        }
        if (node.nodeName === 'BR') {
            return 1;
        }
        let total = 0;
        node.childNodes.forEach(child => {
            total += nodeRawLength(child);
        });
        if (node.nodeName === 'DIV') {
            total += 1;
        }
        return total;
    }

    function notifyHostIfNeeded(text) {
        if (suppressNotification || text === currentRawText) {
            return;
        }
        currentRawText = text;
        if (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.noteChanged) {
            window.webkit.messageHandlers.noteChanged.postMessage({ content: text });
        }
    }

    window.noteBridge = {
        setContent(text) {
            handleInputFromHost(text || '');
        },
        setAppearance(mode) {
            handleThemeChange(mode);
        },
        setTitle() {
            // Reserved for future enhancements.
        },
        focus() {
            editor.focus();
        }
    };

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', initialize, { once: true });
    } else {
        initialize();
    }
})();
