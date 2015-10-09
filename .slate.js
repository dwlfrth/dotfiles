slate.configAll({
    "orderScreensLeftToRight" : false,
    "defaultToCurrentScreen" : true,
});

var primaryScreenID = "0";
var secondaryScreenID = "1";

var pushRight = slate.operation("push", {
    "direction" : "right",
    "style" : "bar-resize:screenSizeX/2",
});

var pushLeft = slate.operation("push", {
    "direction" : "left",
    "style" : "bar-resize:screenSizeX/2",
});

var throwPrimaryScreen = slate.operation("throw", {
    "screen" : primaryScreenID,
});

var throwPrimaryScreenFull = slate.operation("throw", {
    "screen" : primaryScreenID,
    "width" : "screenSizeX",
    "height" : "screenSizeY",
});

var throwSecondaryScreen = slate.operation("throw", {
    "screen" : secondaryScreenID,
});

var throwSecondaryScreenFull = slate.operation("throw", {
    "screen" : secondaryScreenID,
    "width" : "screenSizeX",
    "height" : "screenSizeY",
});

slate.bind("down:ctrl;alt", throwPrimaryScreen);            // Move window to primary screen without modifying size (CTRL+OPTION+DOWN)
slate.bind("up:ctrl;alt", throwSecondaryScreen)             // Move window to secondary screen without modifying size (CTRL+OPTION+UP)
slate.bind("down:ctrl;alt;cmd", throwPrimaryScreenFull);    // Move window to primary screen and make it fullscreen (CTRL+OPTION+COMMAND+DOWN)
slate.bind("up:ctrl;alt;cmd", throwSecondaryScreenFull);    // Move window to secondary screen and make it fullscreen (CTRL+OPTION+COMMAND+UP)
slate.bind("left:ctrl;alt;cmd", pushLeft);                  // Move window to the left (50%) of the actual screen (CTRL+OPTION+COMMAND+LEFT)
slate.bind("right:ctrl;alt;cmd", pushRight);                // Move window to the right (50%) of the actual screen (CTRL+OPTION+COMMAND+RIGHT)
