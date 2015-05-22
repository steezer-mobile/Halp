//
//  ViewController.m
//  Halp
//
//  Created by Danilo Caetano on 5/21/15.
//  Copyright (c) 2015 Steezer Mobile. All rights reserved.
//

#import "STZHomeViewController.h"
#import "EmergencyContact.h"

#import <CoreLocation/CoreLocation.h>
#import <QuartzCore/QuartzCore.h>
#import <MapKit/MapKit.h>

@interface STZHomeViewController () <CLLocationManagerDelegate, MKMapViewDelegate, UIAlertViewDelegate>
@property (nonatomic, strong) RLMRealm *realm;
@property (nonatomic, strong) EmergencyContact *contact;
@property (nonatomic, strong) CLLocationManager *locationManager;

@property (nonatomic, weak) IBOutlet UITextField *contactName;
@property (nonatomic, weak) IBOutlet UITextField *addressField;
@property (nonatomic, weak) IBOutlet UITextField *phoneNumber;
@property (nonatomic, weak) IBOutlet MKMapView *mapView;

@end

@implementation STZHomeViewController

// TODO: Move CLLocationManager into manager class
// TODO: Move RLMObject into manager class

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.mapView.delegate = self;
    
    [self updateLocationManager];
    
    // Get the default Realm
    self.contact = [[EmergencyContact alloc] init];

    RLMResults *hasEmergencyContact = [EmergencyContact objectsWhere:@"id = 1"];
    if (!hasEmergencyContact.count) {
        [self writeToRealmObjectFirstTime];
    } else {
        self.contact = hasEmergencyContact.firstObject;
    }
    
    [self updateViewsWithRealm];
}

// TODO: Extract this from here.
- (void) writeToRealmObjectFirstTime {
    
    // Add to Realm with transaction
    dispatch_queue_t queue = dispatch_get_main_queue();
    dispatch_async(queue, ^{
        [self.contact.realm beginWriteTransaction];
        // Create object
        self.contact.id = 1;
        self.contact.contactName = @"";
        self.contact.address = @"";
        self.contact.phoneNumber = @"";
        self.contact.latitude = 0.0f;
        self.contact.longitude = 0.0f;
        [self.contact.realm addObject:self.contact];
        [self.contact.realm commitWriteTransaction];
    });
}

- (BOOL) updateRealmObject {
    
    // TODO: Add error handling here!
    if (![self validateLabels]) {
        return NO;
    }
    
    dispatch_queue_t queue = dispatch_get_main_queue();
    dispatch_async(queue, ^{
        [self.contact.realm beginWriteTransaction];
        self.contact.contactName = self.contactName.text;
        self.contact.address = self.addressField.text;
        self.contact.phoneNumber = self.phoneNumber.text;
        self.contact.latitude = self.locationManager.location.coordinate.latitude;
        self.contact.longitude = self.locationManager.location.coordinate.longitude;
        [self.contact.realm addObject:self.contact];
        [self.contact.realm commitWriteTransaction];
    });
    
    NSLog(@"Emergency Contact Realm object: %@", self.contact);
    
    return YES;
}

- (BOOL) validateLabels {
    
    NSString *errorMessage = @"";
    
    if (self.contactName.text.length < 1) {
        [self makeTextFieldVisiblyErrored:self.contactName];
        errorMessage = [errorMessage stringByAppendingString:@"Name field required \n"];
    }
    
    if (self.addressField.text.length < 1) {
        [self makeTextFieldVisiblyErrored:self.addressField];
        errorMessage = [errorMessage stringByAppendingString:@"Address field required \n"];
    }
    
    if (self.phoneNumber.text.length < 1) {
        [self makeTextFieldVisiblyErrored:self.phoneNumber];
        errorMessage = [errorMessage stringByAppendingString:@"Phone number field required \n"];
    }
    
    [self makeTextFieldsWholeAgain];
    
    if ([errorMessage length] > 0) {
        [self alertViewWithTitle:@"Error!" message:errorMessage];
        return NO;
    }
    
    return YES;
}

- (void) makeTextFieldVisiblyErrored:(UITextField*)textField {
    textField.backgroundColor = [UIColor colorWithRed:255.f/255.f green:0.f/255.f blue:0.f/255.f alpha:0.75f];
}

- (void) makeTextFieldsWholeAgain {
    for (UITextField *textField in self.view.subviews) {
        if ([textField isKindOfClass:[UITextField class]]) {
            if (textField.text.length > 0) {
                textField.backgroundColor = [UIColor whiteColor];
            }
        }
    }
}

- (void)updateViewsWithRealm {
    self.contactName.text = self.contact.contactName;
    self.phoneNumber.text = self.contact.phoneNumber;
    self.addressField.text = self.contact.address;
}

-(IBAction)saveButtonPressed:(id)sender {
    if ([self updateRealmObject]) {
        [self alertViewWithTitle:@"Save successful!" message:@"Woot!"];
    }
}

- (IBAction)updateCurrentLocationButtonPressed:(id)sender {
    [self updateLocationManager];
}

- (void) updateLocationManager {
    
    self.locationManager.delegate = self;
        NSUInteger code = [CLLocationManager authorizationStatus];
        if (code == kCLAuthorizationStatusNotDetermined && ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)] || [self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)])) {
            // choose one request according to your business.
            if([[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLocationAlwaysUsageDescription"]){
                [self.locationManager requestAlwaysAuthorization];
            } else if([[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLocationWhenInUseUsageDescription"]) {
                [self.locationManager  requestWhenInUseAuthorization];
            } else {
                NSLog(@"Info.plist does not contain NSLocationAlwaysUsageDescription or NSLocationWhenInUseUsageDescription");
            }
        }
    [self.locationManager startUpdatingLocation];
    
    [self.mapView setShowsUserLocation:YES];
    [self.mapView setUserTrackingMode:MKUserTrackingModeFollow animated:YES];
}

- (void) updateMapView {
    MKCoordinateRegion region = { { 0.0, 0.0 }, { 0.0, 0.0 } };
    region.center.latitude = self.locationManager.location.coordinate.latitude;
    region.center.longitude = self.locationManager.location.coordinate.longitude;
    region.span.latitudeDelta = 0.0187f;
    region.span.longitudeDelta = 0.0137f;
    [self.mapView setRegion:region animated:YES];
}

- (void) alertViewWithTitle:(NSString*)title message:(NSString*)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [alert addAction:okAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - CLLocation Delegate methods
-(void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    [self updateMapView];
    [self updateRealmObject];
    [self.locationManager stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
}

@end
