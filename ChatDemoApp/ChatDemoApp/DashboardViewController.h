//
//  DashboardViewController.h
//  ChatDemoApp
//
//  Created by Ranosys on 09/01/17.
//  Copyright © 2017 Ranosys. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DashboardXMPP.h"
#import <CoreData/CoreData.h>

@interface DashboardViewController : DashboardXMPP<NSFetchedResultsControllerDelegate>
{
    NSFetchedResultsController *fetchedResultsController;
    
}

@end
