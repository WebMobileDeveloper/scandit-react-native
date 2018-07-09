import {
  UIManager
} from 'react-native';

export class CommandDispatcher {

  constructor(viewHandle) {
    this.pickerViewHandle = viewHandle;
  }

  startScanning() {
    UIManager.dispatchViewManagerCommand(
      this.pickerViewHandle, UIManager.BarcodePicker.Commands.startScanning, null);
  }

  switchTorchOn(val) {
    UIManager.dispatchViewManagerCommand(
      this.pickerViewHandle, UIManager.BarcodePicker.Commands.switchTorchOn, val);
  }

  stopScanning() {
    UIManager.dispatchViewManagerCommand(
      this.pickerViewHandle, UIManager.BarcodePicker.Commands.stopScanning, null);
  }

  resumeScanning() {
    UIManager.dispatchViewManagerCommand(
      this.pickerViewHandle, UIManager.BarcodePicker.Commands.resumeScanning, null);
  }

  pauseScanning() {
    UIManager.dispatchViewManagerCommand(
      this.pickerViewHandle, UIManager.BarcodePicker.Commands.pauseScanning, null);
  }

  applySettings(scanSettings) {
    UIManager.dispatchViewManagerCommand(
      this.pickerViewHandle,
      UIManager.BarcodePicker.Commands.applySettings, [scanSettings]);
  }

  finishOnScanCallback(session) {
    UIManager.dispatchViewManagerCommand(
      this.pickerViewHandle,
      UIManager.BarcodePicker.Commands.finishOnScanCallback,
      session);
  }
  
  finishOnRecognizeNewCodes(session) {
    UIManager.dispatchViewManagerCommand(
      this.pickerViewHandle,
      UIManager.BarcodePicker.Commands.finishOnRecognizeNewCodes,
      session);
  }

  setBeepEnabled(isEnabled) {
    UIManager.dispatchViewManagerCommand(
      this.pickerViewHandle,
      UIManager.BarcodePicker.Commands.setBeepEnabled, [isEnabled]);
  }

  setVibrateEnabled(isEnabled) {
    UIManager.dispatchViewManagerCommand(
      this.pickerViewHandle,
      UIManager.BarcodePicker.Commands.setVibrateEnabled, [isEnabled]);
  }

  setTorchEnabled(isEnabled) {
    UIManager.dispatchViewManagerCommand(
      this.pickerViewHandle,
      UIManager.BarcodePicker.Commands.setTorchEnabled, [isEnabled]);
  }

  setCameraSwitchVisibility(visibility) {
    UIManager.dispatchViewManagerCommand(
      this.pickerViewHandle,
      UIManager.BarcodePicker.Commands.setCameraSwitchVisibility, [visibility]);
  }

  setTextRecognitionSwitchVisible(isVisible) {
    UIManager.dispatchViewManagerCommand(
      this.pickerViewHandle,
      UIManager.BarcodePicker.Commands.setTextRecognitionSwitchVisible, [isVisible]);
  }

  setViewfinderDimension(x, y, width, height) {
    UIManager.dispatchViewManagerCommand(
      this.pickerViewHandle,
      UIManager.BarcodePicker.Commands.setViewfinderDimension, [x, y, width, height]);
  }

  setTorchButtonMarginsAndSize(leftMargin, topMargin, width, height) {
    UIManager.dispatchViewManagerCommand(
      this.pickerViewHandle,
      UIManager.BarcodePicker.Commands.setTorchButtonMarginsAndSize, [leftMargin, topMargin, width, height]);
  }

  setCameraSwitchMarginsAndSize(leftMargin, topMargin, width, height) {
    UIManager.dispatchViewManagerCommand(
      this.pickerViewHandle,
      UIManager.BarcodePicker.Commands.setCameraSwitchMarginsAndSize, [leftMargin, topMargin, width, height]);
  }

  setViewfinderColor(color) {
    UIManager.dispatchViewManagerCommand(
      this.pickerViewHandle,
      UIManager.BarcodePicker.Commands.setViewfinderColor, [color]);
  }

  setViewfinderDecodedColor(color) {
    UIManager.dispatchViewManagerCommand(
      this.pickerViewHandle,
      UIManager.BarcodePicker.Commands.setViewfinderDecodedColor, [color]);
  }

  setMatrixScanHighlightingColor(state, color) {
    UIManager.dispatchViewManagerCommand(
      this.pickerViewHandle,
      UIManager.BarcodePicker.Commands.setMatrixScanHighlightingColor, [state, color]);
  }

  setOverlayProperty(propName, propValue) {
    UIManager.dispatchViewManagerCommand(
      this.pickerViewHandle,
      UIManager.BarcodePicker.Commands.setOverlayProperty, [propName, propValue]);
  }

  setGuiStyle(style) {
    UIManager.dispatchViewManagerCommand(
      this.pickerViewHandle,
      UIManager.BarcodePicker.Commands.setGuiStyle, [style]);
  }

}
