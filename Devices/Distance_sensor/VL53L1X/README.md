# VL53L1X
This Model uses the C++ Library, by implementing it with the IO Device Builder App. 
To use the VL53L1X_Functions Block, copy the Folder "Sensor_Files" into the same Folder as your Simulink Model and drag and Drop the "VL53L1X_Functions_DDAppGeneratedModel.slx" into your Model.

Notes:
- This Model has only been used on my PC, there might be some issues when trying to run it on another PC.
- The Code doesn't have any sort of implementation, should the Sensor Initialisation fail. This should be fixed with some kind of error Message.
- It is currently set to have a Sample time of 20ms this might be important for future development.