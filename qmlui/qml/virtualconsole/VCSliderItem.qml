/*
  Q Light Controller Plus
  VCSliderItem.qml

  Copyright (c) Massimo Callegari

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

      http://www.apache.org/licenses/LICENSE-2.0.txt

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
*/

import QtQuick 2.0
import QtQuick.Layouts 1.1

import org.qlcplus.classes 1.0
import "."

VCWidgetItem
{
    id: sliderRoot
    property VCSlider sliderObj: null
    property int sliderValue: sliderObj ? sliderObj.value : 0
    property int sliderMode: sliderObj ? sliderObj.sliderMode : VCSlider.Playback

    radius: 2

    onSliderObjChanged:
    {
        setCommonProperties(sliderObj)
    }

    Gradient
    {
        id: submasterHandleGradient
        GradientStop { position: 0; color: "#4c4c4c" }
        GradientStop { position: 0.45; color: "#2c2c2c" }
        GradientStop { position: 0.50; color: "#000" }
        GradientStop { position: 0.55; color: "#111111" }
        GradientStop { position: 1.0; color: "#131313" }
    }

    Gradient
    {
        id: submasterHandleGradientHover
        GradientStop { position: 0; color: "#6c6c6c" }
        GradientStop { position: 0.45; color: "#4c4c4c" }
        GradientStop { position: 0.50; color: "#ffff00" }
        GradientStop { position: 0.55; color: "#313131" }
        GradientStop { position: 1.0; color: "#333333" }
    }

    Gradient
    {
        id: grandMasterHandleGradient
        GradientStop { position: 0; color: "#A81919" }
        GradientStop { position: 0.45; color: "#DB2020" }
        GradientStop { position: 0.50; color: "#000" }
        GradientStop { position: 0.55; color: "#DB2020" }
        GradientStop { position: 1.0; color: "#A81919" }
    }

    Gradient
    {
        id: grandMasterHandleGradientHover
        GradientStop { position: 0; color: "#DB2020" }
        GradientStop { position: 0.45; color: "#F51C1C" }
        GradientStop { position: 0.50; color: "#FFF" }
        GradientStop { position: 0.55; color: "#F51C1C" }
        GradientStop { position: 1.0; color: "#DB2020" }
    }

    Rectangle
    {
        visible: sliderObj && sliderObj.monitorEnabled
        y: slFader.y
        x: parent.width - width
        height: slFader.height
        width: UISettings.listItemHeight * 0.2
        rotation: sliderObj ? (sliderObj.invertedAppearance ? 0 : 180) : 180
        color: UISettings.bgLight
        border.width: 1
        border.color: UISettings.bgStrong

        Rectangle
        {
            x: 1
            y: 1
            color: "#00FF00"
            height: sliderObj ? parent.height * (sliderObj.monitorValue / 255) : 0
            width: parent.width - 2
        }
    }

    ColumnLayout
    {
        anchors.fill: parent
        spacing: 2

        // value text box
        Text
        {
            anchors.horizontalCenter: parent.horizontalCenter
            height: UISettings.listItemHeight
            font: sliderObj ? sliderObj.font : ""
            text: sliderObj ? (sliderObj.valueDisplayStyle === VCSlider.DMXValue ?
                               sliderValue : parseInt((sliderValue * 100) / 255) + "%") : sliderValue
            color: sliderObj ? sliderObj.foregroundColor : "white"
        }

        // the central fader
        QLCPlusFader
        {
            id: slFader
            visible: sliderObj ? sliderObj.widgetStyle === VCSlider.WSlider : false
            anchors.horizontalCenter: parent.horizontalCenter
            Layout.fillHeight: true
            width: parent.width
            rotation: sliderObj ? (sliderObj.invertedAppearance ? 180 : 0) : 0
            from: sliderMode === VCSlider.Level ? sliderObj.levelLowLimit : 0
            to: sliderMode === VCSlider.Level ? sliderObj.levelHighLimit : 255
            value: sliderValue
            handleGradient: sliderMode === VCSlider.Submaster ? submasterHandleGradient :
                            (sliderMode === VCSlider.GrandMaster ? grandMasterHandleGradient : defaultGradient)
            handleGradientHover: sliderMode === VCSlider.Submaster ? submasterHandleGradientHover :
                                 (sliderMode === VCSlider.GrandMaster ? grandMasterHandleGradientHover : defaultGradientHover)
            trackColor: sliderMode === VCSlider.Submaster ? "#77DD73" : defaultTrackColor

            onTouchPressedChanged:
            {
                console.log("Slider touch pressed: " + touchPressed)
                // QML tends to propagate touch events, so temporarily disable
                // the page Flickable interactivity during this operation
                virtualConsole.setPageInteraction(!touchPressed)
            }
            onPositionChanged: if (sliderObj) sliderObj.value = valueAt(position)
        }

        QLCPlusKnob
        {
            id: slKnob
            visible: sliderObj ? sliderObj.widgetStyle === VCSlider.WKnob : false
            anchors.horizontalCenter: parent.horizontalCenter
            Layout.fillHeight: true
            //width: parent.width
            value: sliderValue

            onPositionChanged: if (sliderObj) sliderObj.value = position * 255
        }

        // widget name text box
        Text
        {
            id: sliderText
            //width: sliderRoot.width
            Layout.fillWidth: true
            height: UISettings.listItemHeight
            font: sliderObj ? sliderObj.font : ""
            text: sliderObj ? sliderObj.caption : ""
            color: sliderObj ? sliderObj.foregroundColor : "white"
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.Wrap

            function calculateTextHeight()
            {
                sliderText.wrapMode = Text.NoWrap
                var ratio = Math.ceil(sliderText.paintedWidth / width)
                if (ratio == 0)
                    return

                height = ratio * font.pixelSize
                if (ratio > 1)
                    sliderText.wrapMode = Text.Wrap
            }

            Component.onCompleted: calculateTextHeight()
            onWidthChanged: calculateTextHeight()
            onFontChanged: calculateTextHeight()
            onTextChanged: calculateTextHeight()
        }

        IconButton
        {
            visible: sliderObj ? sliderObj.monitorEnabled : false
            anchors.horizontalCenter: parent.horizontalCenter
            imgSource: "qrc:/reset.svg"
            bgColor: sliderObj && sliderObj.isOverriding ? "red" : UISettings.bgLight
            onClicked: if (sliderObj) sliderObj.isOverriding = false
        }
    }

    DropArea
    {
        id: dropArea
        anchors.fill: parent
        z: 2 // this area must be above the VCWidget resize controls
        keys: [ "function" ]

        onEntered: virtualConsole.setDropTarget(sliderRoot, true)
        onExited: virtualConsole.setDropTarget(sliderRoot, false)
        onDropped:
        {
            // attach function here
            if (drag.source.hasOwnProperty("fromFunctionManager"))
                sliderObj.playbackFunction = drag.source.itemsList[0]
        }

        states: [
            State
            {
                when: dropArea.containsDrag
                PropertyChanges
                {
                    target: sliderRoot
                    color: UISettings.activeDropArea
                }
            }
        ]
    }
}
