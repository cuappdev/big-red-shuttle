import UIKit

class DriverViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var tableView: UITableView!
    let data = UserDefaults.standard
    var loginImage: UIImage?
    var isLoggingOn = false
    var textFieldText: String = ""
    var loginSuccessful: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.topItem?.title = "Settings"
        let closeButton = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(dismissView))
        closeButton.tintColor = .darkGray
        navigationController?.navigationBar.topItem?.rightBarButtonItem = closeButton
        view.backgroundColor = .brslightgrey
        let tableViewFrame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height)
        tableView = UITableView(frame: tableViewFrame, style: .grouped)
        tableView.isScrollEnabled = false
        tableView.dataSource = self
        tableView.delegate = self
        view.addSubview(tableView)
    }
    
    
    func dismissView() {
        dismiss(animated: true, completion: nil)
    }
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Logging Login"
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        if indexPath.row == 0 {
            
            let textField = UITextField(frame: CGRect(x: cell.bounds.width/2 + 20, y: 0, width: cell.bounds.width/2, height: cell.bounds.height))
            cell.textLabel?.text = "Authentication Key"

            if loginImage != nil {
            cell.imageView?.image = loginImage
            textField.text = textFieldText
            }
            textField.placeholder = "Insert Key"
            textField.textAlignment = .right
            textField.returnKeyType = .go
            textField.isSecureTextEntry = true
            textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingDidEndOnExit)
        cell.accessoryView = textField
        } else {
            if loginSuccessful {
                cell.isUserInteractionEnabled = true
                cell.textLabel?.textColor = .black
            } else {
                cell.isUserInteractionEnabled = false
                cell.textLabel?.textColor = .lightGray
                cell.textLabel?.alpha = 0.3
            }
            cell.textLabel?.text = "Log Location"
            let logSwitch = UISwitch()
            logSwitch.isOn = isLoggingOn
            logSwitch.addTarget(self, action: #selector(didToggleLogging), for: .valueChanged)
            cell.accessoryView = logSwitch
        }
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        var footerString = ""
        if loginSuccessful && isLoggingOn{
            footerString = "You are now logging the location of your phone to the application and everyone on the network. Please turn off logging while you are not on the bus."
        } else if loginSuccessful && !isLoggingOn {
            footerString = "You are currently not logging the location of the bus. Click the toggle to start logging."
        } else if !loginSuccessful {
            footerString = "Your Authentication Key is incorrect. You are currently not logging the location."
            }
        
        return footerString
    }
    
    func textFieldDidChange(textField: UITextField) {
        //check if access key is correct if so, unlock cell aka brsxappdev2016
        if textField.text == "brsxappdev2016" {
            loginImage = UIImage(named: "checkmark")
            textFieldText = "brsxappdev2016"
            loginSuccessful = true
            tableView.reloadData()
        } else {
            loginImage = UIImage(named: "incorrect")
            textFieldText = textField.text!
            loginSuccessful = false
            tableView.reloadData()
        }
    }
    
    func didToggleLogging(loggingSwitch: UISwitch) {
        if loggingSwitch.isOn {
            isLoggingOn = true
            //MARK: start logging location
            tableView.reloadData()
        } else {
            isLoggingOn = false
            //MARK stop logging location
            tableView.reloadData()
        }
    }
    

}
