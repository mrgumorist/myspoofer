#include <stdio.h>
#import <Foundation/Foundation.h>
#import "MyControl.h"

int main(int argc, char *argv[], char *envp[]) {
    if(argc == 2)
    {
        if([[NSString stringWithUTF8String:argv[1]] isEqual: @"GetAllSettings"])
        {
            NSLog(@"Success");
        }
        else if([[NSString stringWithUTF8String:argv[1]] isEqual: @"ResetAll"])
        {
            [objc_getClass("MyControl") resetAllSettings];
            NSLog(@"Success");
        }
    }
    else if(argc == 3)
    {
        if([[NSString stringWithUTF8String:argv[1]] isEqual: @"GetOriginalValue"])
        {
            NSString *mgKey = [objc_getClass("MyControl") getOriginalValue: [NSString stringWithUTF8String:argv[2]]];
            NSLog(@"Success %@", mgKey);
        }
    }
    else
    {
        NSLog(@"Arguments count enabled: 2, 3");
    }
    return 0;
}
