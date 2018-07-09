export class MatrixScanSession {

	constructor(newlyTrackedCodes) {
		this.newlyTrackedCodes = newlyTrackedCodes;
		this.shouldPause = false;
		this.shouldStop = false;
		this.rejectedCodes = [];
	}

	pauseScanning() {
		this.shouldPause = true;
	}

	stopScanning() {
		this.shouldStop = true;
	}

	rejectTrackedCode(barcode) {
		this.rejectedCodes.push(barcode.id);
	}

}
