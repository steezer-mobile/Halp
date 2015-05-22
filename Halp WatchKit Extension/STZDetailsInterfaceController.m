//
//  STZDetailsInterfaceController.m
//  Halp
//
//  Created by Danilo Caetano on 5/21/15.
//  Copyright (c) 2015 Steezer Mobile. All rights reserved.
//

#import "STZDetailsInterfaceController.h"

@interface STZDetailsInterfaceController ()

@property (nonatomic, weak) IBOutlet WKInterfaceMap *alertMap;
@property (nonatomic, weak) IBOutlet WKInterfaceLabel *alertSentToLabel;
@property (nonatomic, weak) IBOutlet WKInterfaceDate *alertSentOnDate;

@property (nonatomic, weak) IBOutlet WKInterfaceButton *callButton;
@property (nonatomic, weak) IBOutlet WKInterfaceButton *textButton;

@property (nonatomic, assign) float longitude;
@property (nonatomic, assign) float latitude;
@property (nonatomic, strong) NSString *phoneNumber;
@property (nonatomic, strong) NSString *contactName;

@end

@implementation STZDetailsInterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    
    NSLog(@"%@ awakeWithContext", self);
    [self handleReceiverFromParentApp];
}

- (void)willActivate {
    [super willActivate];
    NSLog(@"%@ will activate", self);
}

- (void)didDeactivate {
    [super didDeactivate];
    NSLog(@"%@ did deactivate", self);
}

- (void) handleReceiverFromParentApp {
    
    NSString *sendTextMessageToContact = @"YES";
    NSDictionary *applicationData = @{@"sendTextMessageToContact" : sendTextMessageToContact};
    
    //Handle reciever in app delegate of parent app
    [WKInterfaceController openParentApplication:applicationData reply:^(NSDictionary *replyInfo, NSError *error) {
        
        NSData *contactNameData = replyInfo[@"contactName"];
        self.contactName = [NSKeyedUnarchiver unarchiveObjectWithData: contactNameData];
        NSData *phoneNumberData = replyInfo[@"phoneNumber"];
        self.phoneNumber = [NSKeyedUnarchiver unarchiveObjectWithData:phoneNumberData];
        [self setupInterfaceLabel];
        
        NSData *latitudeData = replyInfo[@"latitude"];
        self.latitude = [[NSKeyedUnarchiver unarchiveObjectWithData: latitudeData] floatValue];
        NSData *longitudeData = replyInfo[@"longitude"];
        self.longitude = [[NSKeyedUnarchiver unarchiveObjectWithData: longitudeData] floatValue];
        [self setupInterfaceMap];
        
        if (!error) {
            [self sendNotificationToParentAppToContactYourEmergencyContact];
            NSLog(@"replyInfo: %@", replyInfo);
        } else {
            NSLog(@"Error: %@", [error description]);
        }
    }];
}

- (void) setupInterfaceMap {
    CLLocationCoordinate2D mapLocation = CLLocationCoordinate2DMake(self.latitude, self.longitude);
    MKCoordinateSpan coordinateSpan = MKCoordinateSpanMake(1, 1);
    
    [self.alertMap addAnnotation:mapLocation withPinColor: WKInterfaceMapPinColorPurple];
    [self.alertMap setRegion:(MKCoordinateRegionMake(mapLocation, coordinateSpan))];
}

- (void) setupInterfaceLabel {
    [self.alertSentToLabel setText:[NSString stringWithFormat:@"Alert sent to %@ at %@.", self.contactName, self.phoneNumber]];
}

- (void) sendNotificationToParentAppToContactYourEmergencyContact {
    NSLog(@"sendNotificationToParentAppToContactYourEmergencyContact");
    
    [WKInterfaceController openParentApplication:@{@"triggerEmergencyAlert": @"YES"} reply:^(NSDictionary *replyInfo, NSError *error) {
        
    }];
}

@end



