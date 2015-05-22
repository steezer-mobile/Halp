//
//  InterfaceController.m
//  Halp WatchKit Extension
//
//  Created by Danilo Caetano on 5/21/15.
//  Copyright (c) 2015 Steezer Mobile. All rights reserved.
//

#import "STZHomeInterfaceController.h"


@interface STZHomeInterfaceController() <MKMapViewDelegate>

@property (nonatomic, weak) IBOutlet WKInterfaceButton *halpButton;

@end


@implementation STZHomeInterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];

    // Configure interface objects here.
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

@end



