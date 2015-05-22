//
//  EmergencyContact.m
//  Halp
//
//  Created by Danilo Caetano on 5/21/15.
//  Copyright (c) 2015 Steezer Mobile. All rights reserved.
//

#import "EmergencyContact.h"

@implementation EmergencyContact

// Specify default values for properties
+ (NSDictionary *)defaultPropertyValues
{
    return @{@"longitude" : @0.0f, @"latitude": @0.0f, @"contactName": @"", @"phoneNumber": @"", @"id": @0};
}

+ (NSString *)primaryKey {
    return @"id";
}

// Specify properties to ignore (Realm won't persist these)

//+ (NSArray *)ignoredProperties
//{
//    return @[];
//}

@end
