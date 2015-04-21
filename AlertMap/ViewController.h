//
//  ViewController.h
//  AlertMap
//
//  Created by Lucho Escobar on 4/21/15.
//  Copyright (c) 2015 Lucho & Antonio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <MapKit/MKAnnotation.h>
#import <CoreLocation/CoreLocation.h>
#import <MessageUI/MessageUI.h>

@interface ViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate,  MFMessageComposeViewControllerDelegate>

@property (nonatomic, retain) IBOutlet MKMapView *mapView;
@property(nonatomic, retain) CLLocationManager *locationManager;
- (IBAction)zoomtocurrentloc:(id)sender;
- (IBAction)sendSMS:(id)sender;
- (IBAction)drop_pin:(id)sender;

@end

