//
//  ViewController.m
//  AlertMap
//
//  Created by Lucho Escobar on 4/21/15.
//  Copyright (c) 2015 Lucho & Antonio. All rights reserved.
//

#import "ViewController.h"
#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.mapView.delegate = self;
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
#ifdef __IPHONE_8_0
    if(IS_OS_8_OR_LATER) {
        // Use one or the other, not both. Depending on what you put in info.plist
        [self.locationManager requestWhenInUseAuthorization];
        [self.locationManager requestAlwaysAuthorization];
    }
#endif
    
    //Create region
    MKCoordinateRegion region;
    
    //center
    CLLocationCoordinate2D center;
    center.latitude = 41.699;
    center.longitude = -86.239;
    region.center = center;
    
    //span
    region.span.latitudeDelta = 0.01f;
    region.span.longitudeDelta = 0.01f;
    
    //set region, display
    [_mapView setRegion:region animated:YES];
    
    
    [self.locationManager startUpdatingLocation];
    
    self.mapView.showsUserLocation = YES;
    [self.mapView setMapType:MKMapTypeStandard];
    [self.mapView setZoomEnabled:YES];
    [self.mapView setScrollEnabled:YES];
}



-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 800, 800);
    [self.mapView setRegion:[self.mapView regionThatFits:region] animated:YES];
}



#pragma mark Zoom
- (IBAction)zoomtocurrentloc:(id)sender {
    float spanX = 0.00725;
    float spanY = 0.00725;
    MKCoordinateRegion region;
    region.center.latitude = self.mapView.userLocation.coordinate.latitude;
    region.center.longitude = self.mapView.userLocation.coordinate.longitude;
    region.span.latitudeDelta = spanX;
    region.span.longitudeDelta = spanY;
    [self.mapView setRegion:region animated:YES];
    //[self.mapView setCenter:_mapView.userLocation.coordinate animated:YES];
}

#pragma mark Drop Pin
- (IBAction)drop_pin:(id)sender {
    CLLocationCoordinate2D pin;
    pin.latitude = self.mapView.userLocation.coordinate.latitude;
    pin.longitude = self.mapView.userLocation.coordinate.longitude;
    
    MKPointAnnotation *myAnnotation = [[MKPointAnnotation alloc] init];
    myAnnotation.coordinate = pin;
    myAnnotation.title = @"Help";
    NSString * latitude = [NSString stringWithFormat:@"%.3lf", self.mapView.userLocation.coordinate.latitude];
    NSString *longitude = [NSString stringWithFormat:@"%.3lf", self.mapView.userLocation.coordinate.longitude];
    
    myAnnotation.subtitle = [NSString stringWithFormat:@"Latitude:%@ Longitude: %@", latitude, longitude];
    [_mapView addAnnotation:myAnnotation];
    
}

#pragma mark - IBAction methods
-(IBAction)sendSMS:(id)sender {
    //check if the device can send text messages
    if(![MFMessageComposeViewController canSendText]) {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Your device cannot send text messages" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    //coordinate
    NSString * latitude = [NSString stringWithFormat:@"%.3lf", self.mapView.userLocation.coordinate.latitude];
    NSString *longitude = [NSString stringWithFormat:@"%.3lf", self.mapView.userLocation.coordinate.longitude];
    
    //set receipients
    NSArray *recipients = [NSArray arrayWithObjects:@"7865270939", nil];
    
    //set message text
    NSString * message = [NSString stringWithFormat:@"Help. My current location is latitude:%@ longitude: %@", latitude, longitude];
    
    MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
    messageController.messageComposeDelegate = self;
    [messageController setRecipients:recipients];
    [messageController setBody:message];
    
    // Present message view controller on screen
    [self presentViewController:messageController animated:YES completion:nil];
    
}

#pragma mark - MFMailComposeViewControllerDelegate methods
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult) result
{
    switch (result) {
        case MessageComposeResultCancelled:
            break;
            
        case MessageComposeResultFailed:
        {
            UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Error while sendind SMS!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [warningAlert show];
            break;
        }
            
        case MessageComposeResultSent:
            break;
            
        default:
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}



#pragma mark Memory Warning
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end