//
//  main.m
//  NetworkInterfaceDetector
//
//  Created by Thomas Westfeld on 27.01.19.
//  Copyright © 2019 Thomas Westfeld. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SystemConfiguration/SystemConfiguration.h>

/* Callback used if a configuration change on monitored keys was detected.
 */
void dynamicStoreCallback(SCDynamicStoreRef store, CFArrayRef changedKeys, void* __nullable info) {
    CFIndex count = CFArrayGetCount(changedKeys);
    for (CFIndex i=0; i<count; i++) {
        CFStringRef key = CFArrayGetValueAtIndex(changedKeys, i);
        NSLog(@"Key \"%@\" was changed", key);
        CFPropertyListRef ref = SCDynamicStoreCopyValue(store,key);
        NSDictionary * dict = (NSDictionary *)CFBridgingRelease(ref);
        NSLog(@"Value %@", dict);
    }
}

int main(int argc, const char * argv[]) {
    NSArray *SCMonitoringInterfaceKeys = @[@"State:/Network/Interface"];
    NSArray *patterns = @[@"en\\d*/IPv4"];
    @autoreleasepool {
        SCDynamicStoreRef dsr = SCDynamicStoreCreate(NULL, CFSTR("network_interface_detector"), &dynamicStoreCallback, NULL);
        SCDynamicStoreSetNotificationKeys(dsr, CFBridgingRetain(SCMonitoringInterfaceKeys), CFBridgingRetain(patterns));
        CFRunLoopAddSource(CFRunLoopGetCurrent(), SCDynamicStoreCreateRunLoopSource(NULL, dsr, 0), kCFRunLoopDefaultMode);
        NSLog(@"Starting RunLoop...");
        while([[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]]);
    }
    return 0;
}
