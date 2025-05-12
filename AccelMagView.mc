using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.System;
using Toybox.Timer;
using Toybox.SensorLogging;

class AccelMagView extends WatchUi.View {
    var logger;
    var timer;
    var message = "Logging...";

     function initialize() {
        View.initialize(); 
    }

    function onShow() {
        // Start logging accelerometer data
       logger = new SensorLogging.SensorLogger({ :accelerometer => { :enabled => true } });


        // Set up a 10-second timer to stop logging
        timer = new Timer.Timer();
        timer.start(method(:stopLogging), 10 * 1000, false);
    }

   function stopLogging() as Void {
        var stats = logger.getStats2(:accelerometer);

        if (stats != null) {
            message = "Samples: " + stats.sampleCount +
                    "\nDuration: " + stats.duration + " ms";
        } else {
            message = "No data logged.";
        }

        WatchUi.requestUpdate();
        return; 
    }


    function onUpdate(dc) {
        dc.clear();
        dc.drawText(dc.getWidth()/2, dc.getHeight()/2,
            Graphics.FONT_SMALL, message, Graphics.TEXT_JUSTIFY_CENTER);
        WatchUi.requestUpdate(); // Continuous refresh
    }

    function onHide() {
        if (timer != null) {
            timer.stop();
        }
    }
}


// using Toybox.WatchUi;
// using Toybox.Graphics;
// using Toybox.System;
// using Toybox.Sensor;
// using Toybox.Timer;
// using Toybox.FitContributor;

// class AccelMagView extends WatchUi.View {

//     var axField, ayField, azField;
//     var lastZ = 0.0;
//     var timer;

//     function onLayout(dc) {}

//     function onShow() {
//         // Create the custom FIT data field we want to record.
//           axField = new FitContributor.Field("ax", 0, FitContributor.DATA_TYPE_FLOAT,
//             { :mesgType => FitContributor.MESG_TYPE_RECORD, :units => "mg" });

//         ayField = createField(
//             "ay",
//             1,
//             FitContributor.DATA_TYPE_FLOAT,
//             {:mesgType => FitContributor.MESG_TYPE_RECORD, :units=>"mg"}
//         );

//         azField = createField(
//             "az",
//             2,
//             FitContributor.DATA_TYPE_FLOAT,
//             {:mesgType => FitContributor.MESG_TYPE_RECORD, :units=>"mg"}
//         );



//         timer = new Timer.Timer();
//         timer.start(method(:sampleAccel), 1000, true); // every second
//     }

//     function timerCallback() {
//         var sensorInfo = Sensor.getInfo();
//         if (sensorInfo has :accel && sensorInfo.accel != null) {
//             var accel = sensorInfo.accel;
//             var xAccel = accel[0];
//             var yAccel = accel[1];
//             var zAccel = accel[2];
//             System.println("x: " + xAccel + ", y: " + yAccel);
//             axField.setData(xAccel);
//             ayField.setData(yAccel);
//             azField.setData(zAccel);
//         }
//     }   

//     function onUpdate(dc) {
//         dc.clear();
//         dc.drawText(dc.getWidth()/2, dc.getHeight()/2, Graphics.FONT_LARGE, "Z: " + lastZ, Graphics.TEXT_JUSTIFY_CENTER);
//         WatchUi.requestUpdate(); // continuous refresh
//     }

//     function onHide() {
//         timer.stop();
//     }
// }

// class AccelMagView extends WatchUi.SimpleDataField {
//     private const _r = 10;
//     private const _incrFrict = 15;
//     private const _pcntFrict = 99;
//     private const _wallLoss = 80;
//     private const _arrowLen = 25.0;
//     private const _hitForce = 50.0;
//     private const _velocityToPix = 0.004; // 1/250

//     private var _dataTimer as Timer.Timer?;
//     private var _x as Numeric;
//     private var _y as Numeric;
//     private var _xVelocity as Numeric;
//     private var _yVelocity as Numeric;
//     private var _width as Numeric;
//     private var _height as Numeric;
//     private var _xMult as Numeric;
//     private var _yMult as Numeric;

//     private var _accel as Array<Float>;
//     private var _mag as Array<Float>;
//     private var _accelLog as Array<Array<Float>>;
//     var ax = null;
//     var ay = null;
//     var az = null;
//     const ax_FIELD_ID = 0;
//     const ay_FIELD_ID = 1;
//     const az_FIELD_ID = 2;

//     //! Constructor
//     public function initialize() {
//         View.initialize();
//         SimpleDataField.initialize();
        

//         // Initialize our members
//         _x = 0;
//         _y = 0;
//         _xVelocity = 0;
//         _yVelocity = 0;
//         _width = 0;
//         _height = 0;
//         _xMult = 0;
//         _yMult = 0;
//         _accel = new Array<Float>[3];
//         _mag = new Array<Float>[3];
//         _accelLog = [];

//          // Create the custom FIT data field we want to record.
//         ax = createField(
//             "ax",
//             ax_FIELD_ID,
//             FitContributor.DATA_TYPE_FLOAT,
//             {:mesgType => FitContributor.MESG_TYPE_RECORD, :units=>"mg"}
//         );

//         ay = createField(
//             "ay",
//             ay_FIELD_ID,
//             FitContributor.DATA_TYPE_FLOAT,
//             {:mesgType => FitContributor.MESG_TYPE_RECORD, :units=>"mg"}
//         );

//         az = createField(
//             "az",
//             az_FIELD_ID,
//             FitContributor.DATA_TYPE_FLOAT,
//             {:mesgType => FitContributor.MESG_TYPE_RECORD, :units=>"mg"}
//         );


//         ax.setData(0.0);
//         ay.setData(0.0);
//         az.setData(1.0);

//     }

//     //! Initialize members based on the screen resolution
//     //! @param dc Draw context
//     public function onLayout(dc as Dc) {
//         _dataTimer = new Timer.Timer();
//         _dataTimer.start(method(:timerCallback), 100, true);

//         _width = dc.getWidth();
//         _height = dc.getHeight();

//         _x = _width / 2;
//         _y = _height / 2;

//     }

//     //! Restore the state of the app and prepare the view to be shown
//     public function onShow() {
    
//     }

//     //! Update the view
//     //! @param dc Device context
//     public function onUpdate(dc as Dc) as Void {
//         dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
//         dc.clear();

//         dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_RED);
//         dc.fillCircle(_x.toNumber(), _y.toNumber(), _r);

//         if (_mag != null) {
//             dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_LT_GRAY);

//             // Draw arrow stem
//             var xArrow = _x - _xMult * _arrowLen;
//             var yArrow = _y - _yMult * _arrowLen;
//             dc.drawLine(xArrow, yArrow, _x, _y);

//             // Draw first arrow tail
//             var xArrowTail = _x + _yMult * _arrowLen / 2;
//             var yArrowTail = _y - _xMult * _arrowLen / 2;
//             xArrowTail = (xArrowTail + xArrow) / 2;
//             yArrowTail = (yArrowTail + yArrow) / 2;
//             dc.drawLine(xArrowTail, yArrowTail, _x, _y);

//             // Draw second arrow tail
//             xArrowTail = _x - _yMult * _arrowLen / 2;
//             yArrowTail = _y + _xMult * _arrowLen / 2;
//             xArrowTail = (xArrowTail + xArrow) / 2;
//             yArrowTail = (yArrowTail + yArrow) / 2;
//             dc.drawLine(xArrowTail, yArrowTail, _x, _y);
//         }

//         dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
//         if (_accel != null) {
//             dc.drawText(_width / 2,  3, Graphics.FONT_TINY, "Ax = " + _accel[0], Graphics.TEXT_JUSTIFY_CENTER);
//             dc.drawText(_width / 2, 23, Graphics.FONT_TINY, "Ay = " + _accel[1], Graphics.TEXT_JUSTIFY_CENTER);
//             dc.drawText(_width / 2, 43, Graphics.FONT_TINY, "Az = " + _accel[2], Graphics.TEXT_JUSTIFY_CENTER);
//         } else {
//             dc.drawText(_width / 2, 3, Graphics.FONT_TINY, "no Accel", Graphics.TEXT_JUSTIFY_CENTER);
//         }

//         if (_mag != null) {
//             dc.drawText(_width / 2, _height - 70, Graphics.FONT_TINY, "Mx = " + _mag[0], Graphics.TEXT_JUSTIFY_CENTER);
//             dc.drawText(_width / 2, _height - 50, Graphics.FONT_TINY, "My = " + _mag[1], Graphics.TEXT_JUSTIFY_CENTER);
//             dc.drawText(_width / 2, _height - 30, Graphics.FONT_TINY, "Mz = " + _mag[2], Graphics.TEXT_JUSTIFY_CENTER);
//         } else {
//             dc.drawText(_width /2, _height - 30, Graphics.FONT_TINY, "no Mag", Graphics.TEXT_JUSTIFY_CENTER);
//         }

//     }

//      function compute(info) {
//         // Check if accelerometer is available
//         var accel = Sensor.getAccelerometerData;
//         if (accel != null){
//             var acx = accel.x;
//             var acy = accel.y;
//             var acz = accel.z;
//             // Set FIT developer field values
//             ax.setData(acx);
//             ay.setData(acy);
//             az.setData(acz);
//             return acz;
//         }
//         return 0.0;        
//      }

//     //! On a timer interval, read the accelerometer
//     //! and update the ball position
//     public function timerCallback() as Void {
//         var info = Sensor.getInfo();

//         if (info has :accel && info.accel != null) {
//             _accel = info.accel as Array<Float>;
//             _accelLog.add([_accel[0], _accel[1], _accel[2]]);

//             var xAccel = _accel[0];
//             var yAccel = _accel[1] * -1; // Cardinal Y direction is opposite the screen coordinates

//             // Ignore low acceleration values
//             if ((xAccel > _incrFrict) || (xAccel < -1 * _incrFrict)) {
//                 _xVelocity += xAccel;
//             }
//             if ((yAccel > _incrFrict) || (yAccel < -1 * _incrFrict)) {
//                 _yVelocity += yAccel;
//             }

//             // Apply some friction
//             _xVelocity = _xVelocity * _pcntFrict / 100;
//             _yVelocity = _yVelocity * _pcntFrict / 100;
//             if (_xVelocity > _incrFrict) {
//                 _xVelocity -= _incrFrict;
//             } else if (_xVelocity < -1 * _incrFrict) {
//                 _xVelocity += _incrFrict;
//             } else {
//                 _xVelocity = 0;
//             }

//             if (_yVelocity > _incrFrict) {
//                 _yVelocity -= _incrFrict;
//             } else if (_yVelocity < -1 * _incrFrict) {
//                 _yVelocity += _incrFrict;
//             } else {
//                 _yVelocity = 0;
//             }


//             // Move the ball
//             _x += (_xVelocity * _velocityToPix);
//             _y += (_yVelocity * _velocityToPix);

//             // Check for wall collisions
//             if (_x < (0 + _r)) {
//                 _x = 2 * _r - _x;
//                 _xVelocity *= -1;
//                 _xVelocity = _xVelocity * _wallLoss / 100; // remove some energy when bouncing
//             } else if (_x >= (_width - _r)) {
//                 _x = 2 * (_width - _r) - _x;
//                 _xVelocity *= -1;
//                 _xVelocity = _xVelocity * _wallLoss / 100; // remove some energy when bouncing
//             }

//             if (_y < (0 + _r)) {
//                 _y = 2 * _r - _y;
//                 _yVelocity *= -1;
//                 _yVelocity = _yVelocity * _wallLoss / 100; // remove some energy when bouncing
//             } else if (_y >= (_height - _r)) {
//                 _y = 2 * (_height - _r) - _y;
//                 _yVelocity *= -1;
//                 _yVelocity = _yVelocity * _wallLoss / 100; // remove some energy when bouncing
//             }
//         }

//         if ((info has :mag) && (info.mag != null)) {
//             _mag = info.mag as Array<Float>;
//             var xMag = _mag[0];
//             var yMag = _mag[1] * -1; // Cardinal Y direction is opposite the screen coordinates

//             var magMagnitude = Math.sqrt(Math.pow(xMag,2) + Math.pow(yMag,2));

//             if (magMagnitude != 0) {
//                 _xMult = xMag / magMagnitude;
//                 _yMult = yMag / magMagnitude;
//             } else {
//                 _xMult = 0;
//                 _yMult = 0;
//             }
//         }
//         ax.setData(_accel[0]);
//         ay.setData(_accel[1]);
//         az.setData(_accel[2]);

//         WatchUi.requestUpdate();
//     }

//     //! Kick the ball
//     public function kickBall() as Void
//     {
//         if (_mag != null) {
//             _xVelocity += (_xMult * _hitForce / _velocityToPix).toNumber();
//             _yVelocity += (_yMult * _hitForce / _velocityToPix).toNumber();
//         }
//     }

//     //! Called when this View is removed from the screen. Save the
//     //! state of your app here.
//     public function onHide() as Void {
//     }
// }
