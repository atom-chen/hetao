//
//  
//

#ifndef NetUitls_h
#define NetUitls_h

#include <ifaddrs.h>
#include <arpa/inet.h>
#include <net/if.h>

#define IOS_CELLULAR    @"pdp_ip0"
#define IOS_WIFI        @"en0"
//#define IOS_VPN       @"utun0"
#define IP_ADDR_IPv4    @"ipv4"
#define IP_ADDR_IPv6    @"ipv6"

class NetUtils
{
private:
    static NetUtils* _Instance;
    float _topH;
    float _bottomH;
    
public:
    static NetUtils* getInstance(){
        if( _Instance == NULL){
            _Instance = new NetUtils();
        }
        return _Instance;
    }
    void init();
    
    NSString * getIPAddress(BOOL preferIPv4);
    NSDictionary * getIPAddresses();
};


#endif //NetUitls_h
