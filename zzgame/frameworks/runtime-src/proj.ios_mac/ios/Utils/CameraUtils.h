//
//  
//

#ifndef CameraUtils_h
#define CameraUtils_h

class CameraUtils {
    
public:
    static CameraUtils* getInstance();
    
    CameraUtils();
    ~CameraUtils();
    
    void openFlashLight();
    
    void closeFlashLight();
    
    void setFlashLight(bool isOpen);
    
};

#endif //CameraUtils_h
