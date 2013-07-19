//
//  ANMatrix.h
//  MatrixMath
//
//  Created by Alex Nichol on 1/23/13.
//  Copyright (c) 2013 Alex Nichol. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ANMatrix : NSObject <NSCopying> {
    double ** matrixData;
    int rowCount, columnCount;
    
    ANMatrix * lastWorkingMatrix;
}

+ (ANMatrix *)identityMatrix:(int)size;
+ (ANMatrix *)rowExchangeMatrixOfSize:(int)size switchRow:(int)row1 withRow:(int)row2;

- (id)initWithString:(NSString *)string;
- (id)initWithRows:(int)rows columns:(int)columns;
- (int)rowCount;
- (int)columnCount;

- (double)itemAtRow:(int)row column:(int)column;
- (void)setItem:(double)item atRow:(int)row column:(int)column;
- (void)setRows:(int)newRowCount columns:(int)newColumnCount;

- (ANMatrix *)transpose;
- (ANMatrix *)scale:(double)scalar;
- (ANMatrix *)add:(ANMatrix *)anotherMatrix;

- (ANMatrix *)multiply:(ANMatrix *)anotherMatrix;
- (ANMatrix *)rowEchelonTransform:(int *)rank;
- (ANMatrix *)reducedRowEchelonTransform:(int *)rank;

- (ANMatrix *)nullspaceBasis;

- (ANMatrix *)specialSolution:(ANMatrix *)answer;

@end
