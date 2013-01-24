//
//  main.m
//  MatrixMath
//
//  Created by Alex Nichol on 1/23/13.
//  Copyright (c) 2013 Alex Nichol. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ANMatrix.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        NSLog(@"Testing reduced row echelon form...");
        ANMatrix * matrix = [[ANMatrix alloc] initWithString:@"1 2 3 4 5; 6 7 8 9 0"];
        int rank = 0;
        ANMatrix * transform = [matrix reducedRowEchelonTransform:&rank];
        NSLog(@"rank: %d\n%@\ntransform:\n%@", rank, [transform multiply:matrix], transform);
        NSLog(@"Testing rref() special case (inverse)...");
        matrix = [[ANMatrix alloc] initWithString:@"1 2 3; 3 4 5; 6 7 0"];
        NSLog(@"inverse result:\n%@", [matrix reducedRowEchelonTransform:NULL]);
        NSLog(@"Testing nullspace...");
        matrix = [[ANMatrix alloc] initWithString:@"-1 1 0; 0 -1 1; 1 0 -1"];
        NSLog(@"Closed loop nullspace basis:\n%@", [matrix nullspaceBasis]);
        NSLog(@"Testing solution finder...");
        matrix = [[ANMatrix alloc] initWithString:@"1 2 3; 3 4 5; 6 7 0"];
        ANMatrix * result = [[ANMatrix alloc] initWithString:@"1; 2; 3"];
        ANMatrix * solution = [matrix specialSolution:result];
        NSLog(@"solution:\n%@\nreal solution:\n%@", solution,
              [[matrix reducedRowEchelonTransform:NULL] multiply:result]);
    }
    return 0;
}

