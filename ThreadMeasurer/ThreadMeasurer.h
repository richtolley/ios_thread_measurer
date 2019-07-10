//
//  ThreadMeasurer.h
//  ThreadMeasurer
//
//  Created by Richard Tolley on 04/07/2019.
//  Copyright © 2019 Richard Tolley. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef struct {
  unsigned int system;
  unsigned int user;
  unsigned int nice;
  unsigned int idle;
} CPUUsage;

@interface ThreadMeasurer : NSObject
- (void)reportMemory;
- (CPUUsage)cpuUsageValues;
- (NSString *)cpuUsage;
@end

NS_ASSUME_NONNULL_END
