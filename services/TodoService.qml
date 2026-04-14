pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.utils
import qs.config

Singleton {
    id: root

    property var todos: []
    readonly property string todoFile: `${Paths.config}/todos.json`

    function addTodo(text: string): void {
        const newTodo = {
            id: Date.now(),
            text: text,
            checked: false
        };
        const newList = todos.slice();
        newList.push(newTodo);
        todos = newList;
        save();
    }

    function removeTodo(id: real): void {
        todos = todos.filter(todo => todo.id !== id);
        save();
    }

    function toggleTodo(id: real): void {
        const newList = todos.slice();
        const todo = newList.find(t => t.id === id);
        if (todo) {
            todo.checked = !todo.checked;
            todos = newList;
            save();
        }
    }

    function save(): void {
        saveTimer.restart();
    }

    Timer {
        id: saveTimer
        interval: 500
        onTriggered: {
            try {
                fileView.setText(JSON.stringify(root.todos, null, 2));
            } catch (e) {
                console.error("Failed to save todos:", e);
            }
        }
    }

    FileView {
        id: fileView
        path: root.todoFile
        onLoaded: {
            try {
                const data = JSON.parse(text());
                if (Array.isArray(data)) {
                    root.todos = data;
                }
            } catch (e) {
                console.error("Failed to parse todos:", e);
            }
        }
        onLoadFailed: err => {
            if (err !== FileViewError.FileNotFound) {
                console.error("Failed to load todos:", FileViewError.toString(err));
            }
        }
    }

    Component.onCompleted: {
        fileView.reload();
    }
}
