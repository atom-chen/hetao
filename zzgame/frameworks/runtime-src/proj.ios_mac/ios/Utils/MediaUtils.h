//
//  
//

#ifndef MediaUtils_h
#define MediaUtils_h

class MediaUtils {
public:
    MediaUtils();
    ~MediaUtils();
    
    static MediaUtils* getInstance();
    
    void setVolume(float percent);
    
    void setBrightness(float percent);
    
    float getVolume();
    
    float getBrightness();
    
};

#endif // MediaUtils_h
