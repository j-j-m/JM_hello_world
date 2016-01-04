//
//  NSString+Formatting.m
//  Hello World
//
//  Created by Jacob Martin on 12/31/15.
//  Copyright © 2015 Jacob Martin. All rights reserved.
//

#import "NSString+Formatting.h"

//format phone number
@implementation NSString (Formatting)
-(NSString*)formatAsPhoneNumber{
    NSMutableString *strippedString = [NSMutableString
                                       stringWithCapacity:self.length];
    
    NSScanner *scanner = [NSScanner scannerWithString:self];
    NSCharacterSet *numbers = [NSCharacterSet
                               characterSetWithCharactersInString:@"0123456789"];
    
    while ([scanner isAtEnd] == NO) {
        NSString *buffer;
        if ([scanner scanCharactersFromSet:numbers intoString:&buffer]) {
            [strippedString appendString:buffer];
            
        } else {
            [scanner setScanLocation:([scanner scanLocation] + 1)];
        }
    }
    
    return strippedString;
}



//ios 7 safe way to check for substrings
- (BOOL)hasString:(NSString*)string {
    NSRange range = [self rangeOfString:string];
    return range.length != 0;
}
@end
