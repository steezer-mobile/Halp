//
//  EmergencyContact.h
//  Halp
//
//  Created by Danilo Caetano on 5/21/15.
//  Copyright (c) 2015 Steezer Mobile. All rights reserved.
//

#import <Realm/Realm.h>

@class EmergencyContact;

@interface EmergencyContact : RLMObject
@property NSInteger id;
@property float longitude;
@property float latitude;
@property NSString *contactName;
@property NSString *address;
@property NSString *phoneNumber;
@end

// This protocol enables typed collections. i.e.:
// RLMArray<EmergencyContact>
RLM_ARRAY_TYPE(EmergencyContact)

