//
//  AddTaskVC.swift
//  Checkmate
//
//  Created by Mag isb-10 on 04/07/2024.
//

import UIKit
import IQKeyboardManager

class AddTaskVC: UIViewController {
  @IBOutlet weak var taskNameTF: UITextField!
  @IBOutlet weak var reminderView: UIView!
  @IBOutlet weak var priorityView: UIView!
  @IBOutlet weak var dateView: UIView!
  @IBOutlet weak var addBtn: UIButton!
  @IBOutlet weak var reminderTF: UITextField!
  @IBOutlet weak var dateTF: UITextField!
  @IBOutlet weak var priorityTF: UITextField!
  @IBOutlet weak var priorityFlag: UIImageView!
  @IBOutlet weak var priorityPopup: UIView!
  @IBOutlet weak var taskTFLeading: NSLayoutConstraint!
  @IBOutlet weak var priorityBtn: UIButton!
  @IBOutlet weak var reminderBtn: UIButton!
  @IBOutlet weak var dateBtn: UIButton!
  
  var priorities: [(image: UIImage, name: String)] = [
    (UIImage(named: "redFlagFill")!, name: "Priority 1"),
    (UIImage(named: "greyFlag")!, name: "Priority 2"),
  ]
  
  weak var delegate: ViewController?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
    view.addGestureRecognizer(tapGesture)
    
    taskNameTF.borderStyle = .none
    
    addViewBorder(view: dateView)
    addViewBorder(view: reminderView)
    addViewBorder(view: priorityView)
    
    addBtn.setTitle("Add Task", for: .normal)
    addBtn.isEnabled = false
    
    dateBtn.setTitle("", for: .normal)
    reminderBtn.setTitle("", for: .normal)
    priorityBtn.setTitle("", for: .normal)
    
    taskNameTF.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    
    priorityPopup.isHidden = true
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    IQKeyboardManager.shared().isEnabled = false
    
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShowNotification(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHideNotification(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    
    IQKeyboardManager.shared().isEnabled = true
    
    NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
    NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    taskNameTF.becomeFirstResponder()
  }
  
  @IBAction func addTaskBtn(_ sender: Any) {
    guard let taskName = taskNameTF.text, !taskName.isEmpty else {
      return
    }
    
    let dateText: String
    if let dateTextFieldText = dateTF.text, !dateTextFieldText.isEmpty {
      dateText = dateTextFieldText
    } else {
      let formatter = DateFormatter()
      formatter.dateFormat = "dd MMM"
      dateText = formatter.string(from: Date())
    }
    
    let priorityImg: UIImage?
    if let priorityText = priorityTF.text, priorityText == "Priority 1" {
      priorityImg = UIImage(named: "radioBtnRed")
    } else {
      priorityImg = UIImage(named: "radioBtnWhite")
    }
    
    let reminderText = reminderTF.text ?? ""
    
    let newTask = TaskModel(radioImg: priorityImg, taskName: taskName, taskDate: dateText, reminderTime: reminderText)
    
    delegate?.addTask(newTask)
    
    self.dismiss(animated: true, completion: nil)
    print("AddTask btn pressed")
  }
  
  
  @IBAction func dateBtn(_ sender: Any) {
    let datePicker = UIDatePicker()
    datePicker.datePickerMode = .date
    datePicker.frame.size = CGSize(width: 0, height: 200)
    datePicker.addTarget(self, action: #selector(dateChange(datePicker:)), for: UIControl.Event.valueChanged)
    if #available(iOS 14.0, *) {
      datePicker.preferredDatePickerStyle = .inline
    } else {
      // Fallback on earlier versions
    }
    datePicker.maximumDate = Date()
    dateTF.inputView = datePicker
    dateTF.becomeFirstResponder()
    
    print("Date btn pressed\n")
  }
  
  @IBAction func priorityBtn(_ sender: Any) {
    let picker = UIPickerView()
    picker.delegate = self
    picker.dataSource = self
    priorityTF.inputView = picker
    picker.selectRow(0, inComponent: 0, animated: true)
    picker.frame.size = CGSize(width: 0, height: 340)
    priorityTF.becomeFirstResponder()
    
    print("priority btn pressed")
  }
  
  @IBAction func reminderBtn(_ sender: Any) {
    let timePicker = UIDatePicker()
    timePicker.datePickerMode = .time
    timePicker.addTarget(self, action: #selector(timeChange(timePicker:)), for: .valueChanged)
    if #available(iOS 14.0, *) {
      timePicker.preferredDatePickerStyle = .wheels
    }
    let pickerHeight: CGFloat = 320
    timePicker.translatesAutoresizingMaskIntoConstraints = false
    timePicker.heightAnchor.constraint(equalToConstant: pickerHeight).isActive = true
    reminderTF.inputView = timePicker
    reminderTF.becomeFirstResponder()
    
    print("Reminder btn pressed")
  }
  
  func addViewBorder(view: UIView) {
    view.layer.borderColor = UIColor.VIEWGRAY.cgColor
    view.layer.borderWidth = 1
  }
  
  func scheduleAlarm(for date: Date) {
    let content = UNMutableNotificationContent()
    content.title = "\(taskNameTF.text ?? "Task")"
    content.body = "It's time for your task!"
    content.sound = UNNotificationSound(named: UNNotificationSoundName("notification.wav"))
    
    
    let calender = Calendar.current
    let components = calender.dateComponents([.year, .month, .day, .hour, .minute], from: date)
    
    var triggerDate = calender.date(from: components)!
    if triggerDate <= Date() {
      triggerDate = calender.date(byAdding: .day, value: 1, to: triggerDate)!
    }
    
    let triggerComponents = calender.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate)
    let trigger = UNCalendarNotificationTrigger(dateMatching: triggerComponents, repeats: false)
    
    let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
    
    UNUserNotificationCenter.current().add(request) { error in
      if let error = error {
        print("error while setting alarm \(error.localizedDescription)")
      } else {
        print("Alarm scheduled for: \(triggerDate)")
      }
    }
    
  }
  
  @objc func timeChange(timePicker: UIDatePicker) {
    let formatter = DateFormatter()
    formatter.dateFormat = "hh:mm a"
    reminderTF.text = formatter.string(from: timePicker.date)
    
    let calender = Calendar.current
    let currentDate = Date()
    
    var dateComponents = calender.dateComponents([.year, .month, .day, .hour, .minute], from: currentDate)
    dateComponents.hour = calender.component(.hour, from: timePicker.date)
    dateComponents.minute = calender.component(.minute, from: timePicker.date)
    
    if let localTime = calender.date(from: dateComponents) {
      let triggerDate = localTime <= currentDate ? calender.date(byAdding: .day, value: 1, to: localTime)! : localTime
      
      scheduleAlarm(for: localTime)
      
      print("Selected time: \(formatter.string(from: timePicker.date))")
      print("Local time for alarm: \(localTime)")
    } else {
      print("Failed to convert the time to the local time zone")
    }
    
  }
  
  @objc func dateChange(datePicker: UIDatePicker) {
    let selectedDate = datePicker.date
    
    let calender = Calendar.current
    let today = Date()
    
    if calender.isDate(selectedDate, inSameDayAs: today) {
      dateTF.text = "Today"
      dateTF.textColor = .PRIMARYRED
    } else {
      let formatter = DateFormatter()
      formatter.dateFormat = "dd MMM"
      dateTF.text = formatter.string(from: datePicker.date)
      dateTF.textColor = .lightGray
    }
  }
  
  @objc func textFieldDidChange(_ textfield: UITextField) {
    if let text = textfield.text {
      addBtn.isEnabled = !text.isEmpty
    }
  }
  
  @objc func dismissKeyboard() {
    view.endEditing(true)
  }
  
  @objc func keyboardWillShowNotification(notification: NSNotification) {
    guard let userInfo = notification.userInfo, let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
    
    view.frame.origin.y = keyboardFrame.height / 1.1
  }
  
  @objc func keyboardWillHideNotification(notification: NSNotification) {
    view.frame.origin.y = 0
  }
  
  
}

extension AddTaskVC: UIPickerViewDelegate, UIPickerViewDataSource {
  func numberOfComponents(in pickerView: UIPickerView) -> Int {
    return 1
  }
  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    return priorities.count
  }
  func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
    let container = UIView()
    
    let image = UIImageView(image: priorities[row].image)
    image.frame = CGRect(x: 40, y: 0, width: 30, height: 30)
    image.tintColor = (row == 0) ? .PRIMARYRED : .lightGray
    
    let label = UILabel()
    label.text = priorities[row].name
    label.textAlignment = .center
    label.font = .systemFont(ofSize: 20, weight: .semibold)
    label.frame = CGRect(x: 0, y: 0, width: 240, height: 30)
    label.textColor = (row == 0) ? .PRIMARYRED : .lightGray
    
    container.addSubview(image)
    container.addSubview(label)
    
    container.frame = CGRect(x: 0, y: 0, width: 240, height: 30)
    
    return container
  }
  func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    priorityTF.text = priorities[row].name
    priorityTF.textColor = (row == 0) ? .PRIMARYRED : .lightGray
    
    if priorities[row].name == "Priority 1" {
      reminderTF.textColor = .PRIMARYRED
      priorityPopup.isHidden = false
      taskTFLeading.constant = 60
    } else {
      reminderTF.textColor = .lightGray
      priorityPopup.isHidden = true
      taskTFLeading.constant = 20
    }
    
    if row == 0 {
      priorityFlag.image = UIImage(named: "redFlagFill")
    } else {
      priorityFlag.image = UIImage(named: "greyFlag")
    }
  }
  func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
    return 40
  }
}
