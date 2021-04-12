import QtQuick 2.2
import Sailfish.Silica 1.0
import Nemo.Notifications 1.0

Dialog {
    id: editDialog

    property int id
    property var note

    onIdChanged: note = notesModel.getNoteById(id)
    onNoteChanged: {
        dialogHeader.title = note["title"]
        contentArea.text = note["content"]
        favoriteButton.selected = note["favorite"]
        categoryField.text = note["category"]
        modifiedDetail.modified = note["modified"]
        //parseContent()
    }

    property int modified
    property string title
    property string category
    property string content
    property bool favorite
    property string etag
    property bool error
    property string errorMessage

    onAccepted: {
        notesModel.updateNote(id, { 'category': categoryField.text, 'content': contentArea.text, 'favorite': favoriteButton.selected, 'modified': new Date().valueOf() / 1000 } )
    }

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: mainColumn.height + Theme.paddingLarge

        PullDownMenu {
            MenuItem {
                text: qsTr("Reset")
                onClicked: reloadContent()
            }
            MenuItem {
                text: qsTr("Markdown syntax")
                onClicked: pageStack.push(Qt.resolvedUrl("SyntaxPage.qml"))
            }
        }

        Column {
            id: mainColumn
            width: parent.width

            DialogHeader {
                id: dialogHeader
                //title: editDialog.title
            }

            Column {
                width: parent.width
                spacing: Theme.paddingLarge

                /*Separator {
                    width: parent.width
                    color: Theme.primaryColor
                    horizontalAlignment: Qt.AlignHCenter
                }*/

                TextArea {
                    id: contentArea
                    width: parent.width
                    text: content
                    placeholderText: qsTr("No content")
                    font.family: appSettings.useMonoFont ? "DejaVu Sans Mono" : Theme.fontFamily
                    property int preTextLength: 0
                    property var listPrefixes: [/^( *)- /gm, /^( *)\* /gm, /^( *)\+ /gm, /^( *)- \[ \] /gm, /^( *)- \[[xX]\] /gm, /^( *)> /gm, /^( *)\d+. /gm]
                    onTextChanged: {
                        if (editDialog.status === PageStatus.Active &&
                                text.length > preTextLength &&
                                text.charAt(cursorPosition-1) === "\n") {
                            var clipboard = ""
                            var preLine = text.substring(text.lastIndexOf("\n", cursorPosition-2), text.indexOf("\n", cursorPosition-1))
                            listPrefixes.forEach(function(currentValue, index) {
                                var prefix = preLine.match(currentValue)
                                if (prefix !== null) {
                                    if (index === listPrefixes.length-1) {
                                        var newListNumber = parseInt(prefix[0].split(". ")[0]) + 1
                                        clipboard = prefix[0].replace(/\d/gm, newListNumber.toString())
                                    }
                                    else {
                                        clipboard = prefix[0]
                                    }
                                }
                            })
                            if (clipboard !== "") {
                                var tmpClipboard = Clipboard.text
                                Clipboard.text = clipboard
                                contentArea.paste()
                                Clipboard.text = tmpClipboard
                            }
                        }
                        preTextLength = text.length
                    }
                }
            }

            Flow {
                x: Theme.horizontalPageMargin
                width: parent.width - 2*x
                spacing: Theme.paddingMedium
                visible: opacity > 0.0
                opacity: categoryField.focus ? 1.0 : 0.0
                Behavior on opacity { FadeAnimator { } }

                Repeater {
                    id: categoryRepeater
                    model: notesApi.categories
                    BackgroundItem {
                        id: categoryBackground
                        width: categoryRectangle.width
                        height: categoryRectangle.height
                        Rectangle {
                            id: categoryRectangle
                            width: categoryLabel.width + Theme.paddingLarge
                            height: categoryLabel.height + Theme.paddingSmall
                            color: "transparent"
                            border.color: Theme.highlightColor
                            radius: height / 4
                            Label {
                                id: categoryLabel
                                anchors.centerIn: parent
                                text: modelData
                                color: categoryBackground.highlighted ? Theme.highlightColor : Theme.primaryColor
                                font.pixelSize: Theme.fontSizeSmall
                            }
                        }
                        onClicked: categoryField.text = modelData
                    }
                }
            }
            Row {
                x: Theme.horizontalPageMargin
                width: parent.width - x
                IconButton {
                    id: favoriteButton
                    property bool selected: favorite
                    width: Theme.iconSizeMedium
                    icon.source: (selected ? "image://theme/icon-m-favorite-selected?" : "image://theme/icon-m-favorite?") +
                                 (favoriteButton.highlighted ? Theme.secondaryHighlightColor : Theme.secondaryColor)
                    onClicked: {
                        api.updateNote(id, {'favorite': !favorite})
                    }
                }
                TextField {
                    id: categoryField
                    width: parent.width - favoriteButton.width
                    text: category
                    placeholderText: qsTr("No category")
                    label: qsTr("Category")
                    EnterKey.iconSource: "image://theme/icon-m-enter-accept"
                    EnterKey.onClicked: {
                        categoryField.focus = false
                    }
                    onFocusChanged: {
                        if (focus === false && text !== category) {
                            notesModel.updateNote(id, {'content': content, 'category': text}) // This does not seem to work without adding the content
                        }
                    }
                }
            }

            DetailItem {
                id: modifiedDetail
                label: qsTr("Modified")
                property int modified
                onModifiedChanged: value = new Date(modified * 1000).toLocaleString(Qt.locale(), Locale.ShortFormat)
            }
        }

        VerticalScrollDecorator {}
    }

    allowedOrientations: appWindow.allowedOrientations
}
