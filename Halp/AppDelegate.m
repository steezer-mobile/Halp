//
//  AppDelegate.m
//  Halp
//
//  Created by Danilo Caetano on 5/21/15.
//  Copyright (c) 2015 Steezer Mobile. All rights reserved.
//

#import "AppDelegate.h"
#import <Realm/Realm.h>
#import "EmergencyContact.h"
#import "STZDetailsInterfaceController.h"

@interface AppDelegate ()

@property (nonatomic, strong) EmergencyContact *contact;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // Notice setSchemaVersion is set to 1, this is always set manually. It must be
    // higher than the previous version (oldSchemaVersion) or an RLMException is thrown
    [RLMRealm setSchemaVersion:2
                forRealmAtPath:[RLMRealm defaultRealmPath]
            withMigrationBlock:^(RLMMigration *migration, NSUInteger oldSchemaVersion) {
                // We haven’t migrated anything yet, so oldSchemaVersion == 0
                if (oldSchemaVersion < 1) {
                    // Nothing to do!
                    // Realm will automatically detect new properties and removed properties
                    // And will update the schema on disk automatically
                }
            }];
    
    // now that we have called `setSchemaVersion:withMigrationBlock:`, opening an outdated
    // Realm will automatically perform the migration and opening the Realm will succeed
    [RLMRealm defaultRealm];
    
    return YES;
}

- (void)application:(UIApplication *)application handleWatchKitExtensionRequest:(NSDictionary *)userInfo reply:(void(^)(NSDictionary *replyInfo))reply {
    
    // Get the default Realm
    self.contact = [[EmergencyContact alloc] init];
    
    RLMResults *hasEmergencyContact = [EmergencyContact objectsWhere:@"id = 1"];
    if (hasEmergencyContact.count) {
        self.contact = hasEmergencyContact.firstObject;
    }
        
    NSString *sendTextMessageToContact = userInfo[@"sendTextMessageToContact"];
    reply(@{@"sendTextMessageToContact":sendTextMessageToContact});
    
    if ([sendTextMessageToContact isEqualToString:@"YES"]) {
        NSLog(@"Gotta send a text message to %@!", self.contact.contactName);
    }
    
    NSMutableDictionary *replyObject = [NSMutableDictionary new];
    replyObject[@"contactName"] = [NSKeyedArchiver archivedDataWithRootObject: self.contact.contactName];
    replyObject[@"phoneNumber"] = [NSKeyedArchiver archivedDataWithRootObject: self.contact.phoneNumber];
    replyObject[@"address"] = [NSKeyedArchiver archivedDataWithRootObject: self.contact.address];
    replyObject[@"latitude"] = [NSKeyedArchiver archivedDataWithRootObject: [NSString stringWithFormat:@"%f", self.contact.latitude]];
    replyObject[@"longitude"] = [NSKeyedArchiver archivedDataWithRootObject: [NSString stringWithFormat:@"%f", self.contact.longitude]];

    reply(replyObject);
}

@end
