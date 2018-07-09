import { ScanSession } from './ScanSession';
import { MatrixScanSession } from './MatrixScanSession';
import { BarcodeFrame } from './BarcodeFrame';

export class SerializationHelper {

  static serializeScanSession(scanSession) {
    return [scanSession.shouldStop, scanSession.shouldPause,
      scanSession.rejectedCodes];
  }

  static deserializeScanSession(map) {
    return new ScanSession(map.allRecognizedCodes, map.newlyRecognizedCodes,
      map.newlyLocalizedCodes);
  }

  static deserializeMatrixScanSession(map) {
    return new MatrixScanSession(map.newlyTrackedCodes);
  }

  static deserializeFrame(frame) {
    return new BarcodeFrame(frame);
  }

}
