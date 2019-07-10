//
//  ThreadMeasurer.m
//  ThreadMeasurer
//
//  Created by Richard Tolley on 04/07/2019.
//  Copyright © 2019 Richard Tolley. All rights reserved.
//

#import "ThreadMeasurer.h"
#import <mach/mach.h>
#import <sys/sysctl.h>
#import <sys/stat.h>


@implementation ThreadMeasurer

-(void)reportMemory {
  struct mach_task_basic_info info;
  mach_msg_type_number_t size = MACH_TASK_BASIC_INFO_COUNT;
  kern_return_t kerr = task_info(mach_task_self(),
                                 MACH_TASK_BASIC_INFO,
                                 (task_info_t)&info,
                                 &size);
  if( kerr == KERN_SUCCESS ) {
    NSLog(@"Memory in use (in bytes): %llu", info.resident_size);
  } else {
    NSLog(@"Error with task_info(): %s", mach_error_string(kerr));
  }
}

- (CPUUsage)cpuUsageValues {
  kern_return_t kr;
  mach_msg_type_number_t count;
  static host_cpu_load_info_data_t previous_info = {0, 0, 0, 0};
  host_cpu_load_info_data_t info;

  CPUUsage usage = {0, 0, 0, 1};
  count = HOST_CPU_LOAD_INFO_COUNT;

  kr = host_statistics(mach_host_self(), HOST_CPU_LOAD_INFO, (host_info_t)&info, &count);
  if (kr != KERN_SUCCESS) {
    return usage;
  }

  natural_t user   = info.cpu_ticks[CPU_STATE_USER] - previous_info.cpu_ticks[CPU_STATE_USER];
  natural_t nice   = info.cpu_ticks[CPU_STATE_NICE] - previous_info.cpu_ticks[CPU_STATE_NICE];
  natural_t system = info.cpu_ticks[CPU_STATE_SYSTEM] - previous_info.cpu_ticks[CPU_STATE_SYSTEM];
  natural_t idle   = info.cpu_ticks[CPU_STATE_IDLE] - previous_info.cpu_ticks[CPU_STATE_IDLE];
  //natural_t total  = user + nice + system + idle;
  previous_info    = info;

  usage.user = user;
  usage.system = system;
  usage.nice = nice;
  usage.idle = idle;
  //return (user + nice + system) * 100.0 / total;
  return usage;
}

- (NSString *)cpuUsage
{
  kern_return_t kr;
  task_info_data_t tinfo;
  mach_msg_type_number_t task_info_count;

  task_info_count = TASK_INFO_MAX;
  kr = task_info(mach_task_self(), TASK_BASIC_INFO, (task_info_t)tinfo, &task_info_count);
  if (kr != KERN_SUCCESS)
  {
    return @"NA";
  }

  task_basic_info_t      basic_info;
  thread_array_t         thread_list;
  mach_msg_type_number_t thread_count;
  thread_info_data_t     thinfo;
  mach_msg_type_number_t thread_info_count;
  thread_basic_info_t basic_info_th;
  uint32_t stat_thread = 0; // Mach threads

  basic_info = (task_basic_info_t)tinfo;

  // get threads in the task
  kr = task_threads(mach_task_self(), &thread_list, &thread_count);
  if (kr != KERN_SUCCESS)
  {
    return @"NA";
  }
  if (thread_count > 0)
    stat_thread += thread_count;
  long tot_idle = 0;
  long tot_user = 0;
  long tot_kernel = 0;
  int j;

  for (j = 0; j < thread_count; j++)
  {
    thread_info_count = THREAD_INFO_MAX;
    kr = thread_info(thread_list[j], THREAD_BASIC_INFO,
                     (thread_info_t)thinfo, &thread_info_count);
    if (kr != KERN_SUCCESS)
    {
      return nil;
    }

    basic_info_th = (thread_basic_info_t)thinfo;

    if (basic_info_th->flags & TH_FLAGS_IDLE)
    {
      //This is idle
      tot_idle = tot_idle + basic_info_th->user_time.microseconds + basic_info_th->system_time.microseconds;
    } else {
      //This is user
      tot_user = tot_user + basic_info_th->user_time.microseconds;

      //This is kernel
      tot_kernel = tot_kernel + basic_info_th->system_time.microseconds;
    }

  } // for each thread

  kr = vm_deallocate(mach_task_self(), (vm_offset_t)thread_list, thread_count * sizeof(thread_t));
  assert(kr == KERN_SUCCESS);

  long tot_cpu = tot_idle + tot_user + tot_kernel;

  return [NSString stringWithFormat:@"Idle: %.2f, User: %.2f, Kernel: %.2f", tot_idle/tot_cpu, tot_user/tot_cpu, tot_kernel/tot_cpu];
}

@end
