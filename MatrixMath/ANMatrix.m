//
//  ANMatrix.m
//  MatrixMath
//
//  Created by Alex Nichol on 1/23/13.
//  Copyright (c) 2013 Alex Nichol. All rights reserved.
//

#import "ANMatrix.h"

#define kAdmissiblePivotValue 0.00000001

@interface ANMatrix (Private)

- (id)initWithRows:(int)rows columns:(int)columns data:(double **)theData;

@end

@implementation ANMatrix

+ (ANMatrix *)identityMatrix:(int)size {
    ANMatrix * matrix = [[ANMatrix alloc] initWithRows:size columns:size];
    for (int i = 0; i < size; i++) {
        [matrix setItem:1 atRow:i column:i];
    }
    return matrix;
}

+ (ANMatrix *)rowExchangeMatrixOfSize:(int)size switchRow:(int)row1 withRow:(int)row2 {
    ANMatrix * matrix = [[ANMatrix alloc] initWithRows:size columns:size];
    for (int i = 0; i < size; i++) {
        if (i == row1) {
            [matrix setItem:1 atRow:i column:row2];
        } else if (i == row2) {
            [matrix setItem:1 atRow:i column:row1];
        } else {
            [matrix setItem:1 atRow:i column:i];
        }
    }
    return matrix;
}

- (id)initWithString:(NSString *)string {
    if ((self = [super init])) {
        NSArray * lines = [string componentsSeparatedByString:@";"];
        if ([lines count] == 0) return nil;
        
        NSCharacterSet * whitespace = [NSCharacterSet whitespaceCharacterSet];
        
        NSArray * firstComponents = [[lines objectAtIndex:0] componentsSeparatedByString:@" "];
        columnCount = (int)[firstComponents count];
        rowCount = (int)[lines count];
        matrixData = (double **)malloc(rowCount * sizeof(double *));
        for (int j = 0; j < rowCount; j++) {
            matrixData[j] = (double *)malloc(columnCount * sizeof(double));
        }
        for (int i = 0; i < [lines count]; i++) {
            NSArray * columnData = [[[lines objectAtIndex:i] stringByTrimmingCharactersInSet:whitespace] componentsSeparatedByString:@" "];
            if ([columnData count] != columnCount) {
                return nil;
            }
            for (int columnIndex = 0; columnIndex < [columnData count]; columnIndex++) {
                matrixData[i][columnIndex] = [[[columnData objectAtIndex:columnIndex] stringByTrimmingCharactersInSet:whitespace] doubleValue];
            }
        }
    }
    return self;
}

- (id)initWithRows:(int)rows columns:(int)columns {
    if ((self = [super init])) {
        rowCount = rows;
        columnCount = columns;
        matrixData = (double **)malloc(rows * sizeof(double *));
        for (int i = 0; i < rows; i++) {
            matrixData[i] = (double *)malloc(columns * sizeof(double));
            bzero(matrixData[i], sizeof(double) * columns);
        }
    }
    return self;
}

- (int)rowCount {
    return rowCount;
}

- (int)columnCount {
    return columnCount;
}

- (NSString *)description {
    NSMutableString * text = [[NSMutableString alloc] init];
    for (int row = 0; row < rowCount; row++) {
        for (int column = 0; column < columnCount; column++) {
            NSString * number = [NSString stringWithFormat:@"%.07f", [self itemAtRow:row column:column]];
            [text appendFormat:@"%@%@", number, column < columnCount - 1 ? @",\t\t" : @"\n"];
        }
    }
    return text;
}

#pragma mark - Elements -

- (double)itemAtRow:(int)row column:(int)column {
    return matrixData[row][column];
}

- (void)setItem:(double)item atRow:(int)row column:(int)column {
    matrixData[row][column] = item;
}

- (void)setRows:(int)newRowCount columns:(int)newColumnCount {
    if (newColumnCount != columnCount) {
        for (int i = 0; i < rowCount; i++) {
            double * rowBuffer = matrixData[i];
            rowBuffer = (double *)realloc(rowBuffer, sizeof(double) * newColumnCount);
            if (newColumnCount > columnCount) {
                bzero(&rowBuffer[columnCount], sizeof(double) * (newColumnCount - columnCount));
            }
            matrixData[i] = rowBuffer;
        }
        columnCount = newColumnCount;
    }
    if (newRowCount < rowCount) {
        for (int i = newRowCount; i < rowCount; i++) {
            free(matrixData[i]);
        }
        matrixData = (double **)realloc(matrixData, sizeof(double *) * newRowCount);
        rowCount = newRowCount;
    } else {
        matrixData = (double **)realloc(matrixData, sizeof(double *) * newRowCount);
        for (int i = rowCount; i < newRowCount; i++) {
            matrixData[i] = malloc(sizeof(double) * columnCount);
            bzero(matrixData[i], sizeof(double) * columnCount);
        }
        rowCount = newRowCount;
    }
}

#pragma mark - Basic Operations -

- (ANMatrix *)transpose {
    ANMatrix * transpose = [[ANMatrix alloc] initWithRows:[self columnCount] columns:[self rowCount]];
    for (int column = 0; column < [self rowCount]; column++) {
        for (int row = 0; row < [self columnCount]; row++) {
            double myItem = [self itemAtRow:column column:row];
            [transpose setItem:myItem atRow:row column:column];
        }
    }
    return transpose;
}

- (ANMatrix *)scale:(double)scalar {
    ANMatrix * scaled = [self copy];
    for (int i = 0; i < [self rowCount]; i++) {
        for (int j = 0; j < [self columnCount]; j++) {
            [scaled setItem:([self itemAtRow:i column:j] * scalar) atRow:i column:j];
        }
    }
    return scaled;
}

- (ANMatrix *)add:(ANMatrix *)anotherMatrix {
    NSAssert(anotherMatrix.columnCount == columnCount && anotherMatrix.rowCount == rowCount, @"Invalid dimensions.");
    ANMatrix * sum = [[ANMatrix alloc] initWithRows:self.rowCount columns:self.columnCount];
    for (int i = 0; i < [self rowCount]; i++) {
        for (int j = 0; j < [self columnCount]; j++) {
            double myItem = [self itemAtRow:i column:j];
            double itsItem = [anotherMatrix itemAtRow:i column:j];
            [sum setItem:(myItem + itsItem) atRow:i column:j];
        }
    }
    return sum;
}

- (ANMatrix *)multiply:(ANMatrix *)anotherMatrix {
    if ([anotherMatrix rowCount] != [self columnCount]) return nil;
    ANMatrix * newMatrix = [[ANMatrix alloc] initWithRows:[self rowCount]
                                                  columns:[anotherMatrix columnCount]];
    for (int row = 0; row < rowCount; row++) {
        for (int column = 0; column < [anotherMatrix columnCount]; column++) {
            double sum = 0;
            for (int i = 0; i < [self columnCount]; i++) {
                double ourValue = [self itemAtRow:row column:i];
                double otherValue = [anotherMatrix itemAtRow:i column:column];
                sum += ourValue * otherValue;
            }
            [newMatrix setItem:sum atRow:row column:column];
        }
    }
    return newMatrix;
}

- (ANMatrix *)rowEchelonTransform:(int *)rank {
    if (rank) *rank = 0;
    ANMatrix * transformation = [ANMatrix identityMatrix:[self rowCount]];
    ANMatrix * workingMatrix = [self copy];
    int pivotsCompleted = 0;
    for (int column = 0; column < [workingMatrix columnCount] && pivotsCompleted < [workingMatrix rowCount]; column++) {
        // check for the next row available as a pivot column
        int pivotRow = -1;
        for (int rowCheck = pivotsCompleted; rowCheck < [workingMatrix rowCount]; rowCheck++) {
            if (fabs([workingMatrix itemAtRow:rowCheck column:column]) > kAdmissiblePivotValue) {
                pivotRow = rowCheck;
                break;
            }
        }
        if (pivotRow < 0) continue;
        if (pivotRow != pivotsCompleted) {
            // row exchange is necessary
            ANMatrix * exchange = [ANMatrix rowExchangeMatrixOfSize:[workingMatrix rowCount]
                                                          switchRow:pivotsCompleted
                                                            withRow:pivotRow];
            transformation = [exchange multiply:transformation];
            workingMatrix = [exchange multiply:workingMatrix];
        }
        // subtract the right amount of the pivot row from the lower rows
        if (rank) *rank += 1;
        double pivotValue = [workingMatrix itemAtRow:pivotsCompleted column:column];
        pivotsCompleted += 1;
        
        ANMatrix * subtractionMatrix = [ANMatrix identityMatrix:[workingMatrix rowCount]];
        for (int rowReduce = pivotsCompleted; rowReduce < [workingMatrix rowCount]; rowReduce++) {
            if ([workingMatrix itemAtRow:rowReduce column:column] != 0) {
                double subtractAmount = [workingMatrix itemAtRow:rowReduce column:column] / pivotValue;
                [subtractionMatrix setItem:-subtractAmount atRow:rowReduce column:(pivotsCompleted - 1)];
            }
        }
        transformation = [subtractionMatrix multiply:transformation];
        workingMatrix = [subtractionMatrix multiply:workingMatrix];
    }
    lastWorkingMatrix = workingMatrix;
    return transformation;
}

- (ANMatrix *)reducedRowEchelonTransform:(int *)rank {
    ANMatrix * transform = [self rowEchelonTransform:rank];
    ANMatrix * workingMatrix = lastWorkingMatrix;
    
    for (int row = workingMatrix.rowCount - 1; row >= 0; row--) {
        int pivotColumn = -1;
        for (int i = 0; i < workingMatrix.columnCount; i++) {
            if (fabs([workingMatrix itemAtRow:row column:i]) > kAdmissiblePivotValue) {
                pivotColumn = i;
                break;
            }
        }
        if (pivotColumn < 0) continue;
        double pivotValue = [workingMatrix itemAtRow:row column:pivotColumn];
        ANMatrix * deduceMatrix = [ANMatrix identityMatrix:[transform rowCount]];
        for (int i = row - 1; i >= 0; i--) {
            double columnValue = [workingMatrix itemAtRow:i column:pivotColumn];
            if (columnValue != 0) {
                double reduceScale = columnValue / pivotValue;
                [deduceMatrix setItem:-reduceScale atRow:i column:row];
            }
        }
        [deduceMatrix setItem:(1 / pivotValue) atRow:row column:pivotColumn];
        transform = [deduceMatrix multiply:transform];
        workingMatrix = [deduceMatrix multiply:workingMatrix];
    }
    
    lastWorkingMatrix = workingMatrix;
    return transform;
}

#pragma mark - Spaces -

- (ANMatrix *)nullspaceBasis {
    int rank;
    [self reducedRowEchelonTransform:&rank];
    ANMatrix * reducedRowEchelon = lastWorkingMatrix;
    
    if (rank == [self columnCount]) return nil; // nullspace is empty
    int * columnTypes = (int *)malloc(sizeof(int) * [self columnCount]); // 1 = pivot, 0 = free
    bzero(columnTypes, sizeof(int) * [self columnCount]);
    // find all the pivot columns to distinguish our free variables
    for (int i = 0; i < [reducedRowEchelon rowCount]; i++) {
        for (int col = 0; col < [reducedRowEchelon columnCount]; col++) {
            if (fabs([reducedRowEchelon itemAtRow:i column:col]) > kAdmissiblePivotValue) {
                columnTypes[col] = 1;
                break;
            }
        }
    }
    ANMatrix * nullspace = [[ANMatrix alloc] initWithRows:[self columnCount] columns:([self columnCount] - rank)];
    int nullspaceColumnIndex = 0;
    for (int freeVariable = 0; freeVariable < [self columnCount]; freeVariable++) {
        if (columnTypes[freeVariable] == 1) continue;
        
        int * decidedValues = (int *)malloc(sizeof(int) * [self columnCount]);
        bzero(decidedValues, sizeof(int) * [self columnCount]);
        decidedValues[freeVariable] = 1;
        [nullspace setItem:1 atRow:freeVariable column:nullspaceColumnIndex];
        // go bottom up and figure out the values one by one
        for (int i = [self rowCount] - 1; i >= 0; i--) {
            double decidedSum = 0;
            for (int j = 0; j < [self columnCount]; j++) {
                if (decidedValues[j] == 0) continue;
                decidedSum += [nullspace itemAtRow:j column:nullspaceColumnIndex] * [reducedRowEchelon itemAtRow:i
                                                                                                          column:j];
            }
            int undecidedIndex = -1;
            for (int j = 0; j < [self columnCount]; j++) {
                if (decidedValues[j] != 0) continue;
                if (fabs([reducedRowEchelon itemAtRow:i column:j]) > kAdmissiblePivotValue) {
                    undecidedIndex = j;
                    break;
                }
            }
            if (undecidedIndex < 0) continue;
            double killValue = [reducedRowEchelon itemAtRow:i column:undecidedIndex];
            [nullspace setItem:-decidedSum/killValue atRow:undecidedIndex column:nullspaceColumnIndex];
            decidedValues[undecidedIndex] = 1;
        }
        
        free(decidedValues);
        
        nullspaceColumnIndex++;
    }
    free(columnTypes);
    return nullspace;
}

#pragma mark - Solutions -

- (ANMatrix *)specialSolution:(ANMatrix *)answer {
    NSAssert(answer.rowCount == self.rowCount, @"Invalid solution dimensions");
    
    ANMatrix * echelonTransform = [self reducedRowEchelonTransform:NULL];
    ANMatrix * reducedRowEchelon = [echelonTransform multiply:self];
    ANMatrix * answerReduced = [echelonTransform multiply:answer];
    
    ANMatrix * solutionMatrix = [[ANMatrix alloc] initWithRows:self.columnCount columns:1];
    for (int row = 0; row < self.rowCount; row++) {
        int pivotColumn = -1;
        for (int column = 0; column < self.columnCount; column++) {
            if ([reducedRowEchelon itemAtRow:row column:column] != 0) {
                pivotColumn = column;
                break;
            }
        }
        if (pivotColumn < 0) {
            if ([answerReduced itemAtRow:row column:0] != 0) {
                // there cannot be a solution; we can't make a non-zero here
                return nil;
            } else continue;
        }
        [solutionMatrix setItem:[answerReduced itemAtRow:row column:0] atRow:pivotColumn column:0];
    }
    
    return solutionMatrix;
}

#pragma mark - Memory -

- (id)copyWithZone:(NSZone *)zone {
    ANMatrix * matrix = [[ANMatrix allocWithZone:zone] initWithRows:rowCount
                                                            columns:columnCount
                                                               data:matrixData];
    return matrix;
}

- (void)dealloc {
    if (matrixData) {
        for (int i = 0; i < rowCount; i++) {
            free(matrixData[i]);
        }
        free(matrixData);
    }
}

#pragma mark - Private -

- (id)initWithRows:(int)rows columns:(int)columns data:(double **)theData {
    if ((self = [super init])) {
        rowCount = rows;
        columnCount = columns;
        matrixData = (double **)malloc(sizeof(double *) * rows);
        for (int i = 0; i < rows; i++) {
            matrixData[i] = (double *)malloc(sizeof(double) * columns);
            memcpy(matrixData[i], theData[i], sizeof(double) * columns);
        }
    }
    return self;
}

@end
