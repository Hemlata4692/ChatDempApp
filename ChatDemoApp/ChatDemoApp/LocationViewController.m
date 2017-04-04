//
//  LocationViewController.m
//  ChatDemoApp
//
//  Created by Ranosys on 24/02/17.
//  Copyright © 2017 Ranosys. All rights reserved.
//

#import "LocationViewController.h"

@import GoogleMaps;
@import GooglePlacePicker;

@interface LocationViewController ()<GMSMapViewDelegate,CLLocationManagerDelegate> {

    BOOL isSelectedLocation;
    
    //Google map variables
    GMSCameraPosition *camera;
    GMSMarker *marker;
    CLLocationCoordinate2D currentLocation;
    CLLocationManager *locationManager;
    
    GMSPlacesClient *_placesClient;//For current location
}

@property (strong, nonatomic) IBOutlet UILabel *NavigationTitle;
@property (strong, nonatomic) IBOutlet UIButton *cancelButton;
@property (strong, nonatomic) IBOutlet UIButton *sendButton;

@property (strong, nonatomic) IBOutlet GMSMapView *googleMapView;
@property (strong, nonatomic) IBOutlet UILabel *currentSelectedPlaceName;
@property (strong, nonatomic) IBOutlet UITextView *currentSelectedAddress;

@property (strong, nonatomic) IBOutlet UIView *currentLocationView;
@property (strong, nonatomic) IBOutlet UIView *selectedLcoationView;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *indicator;
@end

@implementation LocationViewController
@synthesize latitude,longitude, address;

#pragma mark - View life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
//    self.navigationController.navigationBarHidden=YES;
    self.NavigationTitle.text=@"Location";
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
    [self initialized];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - end

#pragma mark - View initializer
- (void)initialized {
    
    isSelectedLocation=NO;
    self.sendButton.hidden=NO;
    marker = [[GMSMarker alloc] init];
    _placesClient = [GMSPlacesClient sharedClient];//For current location
    _sendButton.hidden=YES;
    if (latitude) {
        _indicator.hidden=YES;
        isSelectedLocation=YES;
        self.sendButton.hidden=YES;
        currentLocation.latitude=[latitude doubleValue];
        currentLocation.longitude=[longitude doubleValue];
        
        self.currentLocationView.hidden=YES;
        self.selectedLcoationView.translatesAutoresizingMaskIntoConstraints=YES;
        self.selectedLcoationView.frame=CGRectMake(0, 278, self.view.bounds.size.width, 85);
        
        self.currentSelectedPlaceName.text = [[address componentsSeparatedByString:@","] objectAtIndex:0];
        for (int i=1; i<[[address componentsSeparatedByString:@","] count]; i++) {
            if (i==1) {
                self.currentSelectedAddress.text = [[address componentsSeparatedByString:@","] objectAtIndex:i];
            }
            else {
                self.currentSelectedAddress.text = [NSString stringWithFormat:@"%@,%@",self.currentSelectedAddress.text,[[address componentsSeparatedByString:@","] objectAtIndex:i]];
            }
        }
        [self setGoogleMapData];
    }
    else {
    
        self.indicator.hidden=NO;
        locationManager = [[CLLocationManager alloc] init];
        //Make this controller the delegate for the location manager.
        [locationManager setDelegate:self];
        if ([locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]||[locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
            
            [locationManager requestAlwaysAuthorization];//--------Show blue line during background location update------
        }
        //Set some paramater for the location object.
        [locationManager setDistanceFilter:kCLDistanceFilterNone];
        [locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    }
}

- (void)getCurrentLocation {

    [_placesClient currentPlaceWithCallback:^(GMSPlaceLikelihoodList *placeLikelihoodList, NSError *error){
        if (error != nil) {
            NSLog(@"Pick Place error %@", [error localizedDescription]);
            return;
        }
        
 if (placeLikelihoodList != nil) {
            GMSPlace *place = [[[placeLikelihoodList likelihoods] firstObject] place];
            if (place != nil) {
                
                self.currentSelectedPlaceName.text = place.name;
//                self.currentSelectedAddress.text = [[place.formattedAddress componentsSeparatedByString:@", "]
//                                          componentsJoinedByString:@"\n"];
                self.currentSelectedAddress.text = place.formattedAddress;
                
                currentLocation=place.coordinate;
                self.indicator.hidden=YES;
                _sendButton.hidden=NO;
                [self setGoogleMapData];
            }
        }
    }];
}
#pragma mark - end

#pragma mark - Location authorization status delegate
-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    switch (status)
    {
        case kCLAuthorizationStatusNotDetermined:
        {
            [self showLocationSettingAlert];
        }
            break;
        case kCLAuthorizationStatusRestricted:{
            [self showLocationSettingAlert];
        }
            break;
        case kCLAuthorizationStatusDenied:
        {
            if ([CLLocationManager locationServicesEnabled]) {
                
                [self showLocationSettingAlert];
            }
        }
            break;
        case kCLAuthorizationStatusAuthorizedWhenInUse:
        case kCLAuthorizationStatusAuthorizedAlways:
        {
            [locationManager requestAlwaysAuthorization];
            [self getCurrentLocation];
        }
            break;
            
        default:
        {
            //            [self getCurrentLocation];
        }
            break;
    }
}
#pragma mark - end

#pragma mark - Set pin on google map
- (void)setGoogleMapData {
    
    camera = [GMSCameraPosition cameraWithLatitude:currentLocation.latitude
                                         longitude:currentLocation.longitude
                                              zoom:14.0];
    self.googleMapView.camera = camera;
    marker.position = currentLocation;
    //    marker.tappable = true;
    marker.map= self.googleMapView;
    //    marker.draggable = true;
}
#pragma mark - end

#pragma mark - View IBActions
- (IBAction)cancel:(UIButton *)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)currentLocation:(UIButton *)sender {
    
    self.indicator.hidden=NO;
    [self getCurrentLocation];
}

- (IBAction)send:(UIButton *)sender {
    
    [_delegate sendLocationDelegateAction:[NSString stringWithFormat:@"%@, %@",self.currentSelectedPlaceName.text, self.currentSelectedAddress.text ] latitude:[NSString stringWithFormat:@"%f",currentLocation.latitude] longitude:[NSString stringWithFormat:@"%f",currentLocation.longitude]];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSString *)pb_takeSnapshot {
    UIGraphicsBeginImageContext(self.googleMapView.bounds.size);
    
    [self.googleMapView.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage *screenShot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return [myDelegate setMapImageInLocalDB:screenShot];
}

- (IBAction)mapClick:(UIButton *)sender {
    
    if (!isSelectedLocation) {
        self.indicator.hidden=NO;
        //        CLLocationCoordinate2D center;
        CLLocationCoordinate2D northEast;
        CLLocationCoordinate2D southWest;
        GMSPlacePicker *placePicker;
        
        northEast = CLLocationCoordinate2DMake(currentLocation.latitude + 10, currentLocation.longitude + 10);
        southWest = CLLocationCoordinate2DMake(currentLocation.latitude - 10, currentLocation.longitude - 10);
        //                }
        GMSCoordinateBounds *viewport = [[GMSCoordinateBounds alloc] initWithCoordinate:northEast
                                                                             coordinate:southWest];
        GMSPlacePickerConfig *config = [[GMSPlacePickerConfig alloc] initWithViewport:viewport];
        
        placePicker = [[GMSPlacePicker alloc] initWithConfig:config];
        
        [placePicker pickPlaceWithCallback:^(GMSPlace *place, NSError *error) {
            if (error != nil) {
                NSLog(@"Pick Place error %@", [error localizedDescription]);
                return;
            }
            
            if (place != nil) {
                
                if (NULL!=place.formattedAddress) {
                    //set pin om map
                    self.indicator.hidden=YES;
                    self.currentSelectedPlaceName.text = place.name;
                    //                self.currentSelectedAddress.text = [[place.formattedAddress componentsSeparatedByString:@", "]
                    //                                          componentsJoinedByString:@"\n"];
                    self.currentSelectedAddress.text = place.formattedAddress;
                    
                    currentLocation=place.coordinate;
                }
                _sendButton.hidden=NO;
                [self setGoogleMapData];
            }
            else {
                self.indicator.hidden=YES;
                NSLog(@"No place selected");
            }
        }];
    }
}
#pragma mark - end

#pragma mark - Show location alert
- (void)showLocationSettingAlert {

    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@"Alert"
                                          message:@"Turn on Location Services to allow WhatsMyApp to determine your location."
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:@"Settings"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action)
                               {
                                   
                                   NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                                   [[UIApplication sharedApplication] openURL:url];
                                   [alertController dismissViewControllerAnimated:YES completion:nil];
                               }];
    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:@"Cancel"
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction *action)
                                   {
                                       [alertController dismissViewControllerAnimated:YES completion:nil];
                                   }];
    [alertController addAction:cancelAction];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}
#pragma mark - end
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
