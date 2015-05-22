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
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
    NSLog(@"%@ will activate", self);
    
    [self handleReceiverFromParentApp];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
    NSLog(@"%@ did deactivate", self);
}

- (void) handleReceiverFromParentApp {
    
    NSString *latitudeString = [NSString stringWithFormat:@"%f", self.latitude];
    NSDictionary *applicationData = [[NSDictionary alloc] initWithObjects:@[latitudeString] forKeys:@[@"latitude"]];
    
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
    }];
}

- (void) setupInterfaceMap {
    // Determine a location to display - Apple headquarters
    // TODO: Grab coordinates from data source
    CLLocationCoordinate2D mapLocation = CLLocationCoordinate2DMake(self.latitude, self.longitude);
    
    MKCoordinateSpan coordinateSpan = MKCoordinateSpanMake(1, 1);
    
    // Other colors include red and green pins
    [self.alertMap addAnnotation:mapLocation withPinColor: WKInterfaceMapPinColorPurple];
    [self.alertMap setRegion:(MKCoordinateRegionMake(mapLocation, coordinateSpan))];
}

- (void) setupInterfaceLabel {
    [self.alertSentToLabel setText:[NSString stringWithFormat:@"Alert sent to %@ at %@.", self.contactName, self.phoneNumber]];
}

@end



