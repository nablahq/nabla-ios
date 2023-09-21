//
//  SearchPointViewController.swift
//  ble-tbt-navigation-ios
//
//  Created by Jaksa Tomovic on 05.09.2023..
//

import UIKit
import MapboxSearch

class SearchPointViewController: UIViewController, UITextFieldDelegate {
    
    let searchEngine = SearchEngine()

    let isStartPoint : Bool
    
    init(isStartPoint: Bool) {
        self.isStartPoint = isStartPoint
        super.init(nibName: nil, bundle: nil)
    }
    
    lazy var searchBoxContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 1, alpha: 0.9)
        return view
    }()
    
    
    lazy var tableView: UITableView = {
        let tv = UITableView()
        tv.backgroundColor = UIColor(white: 1, alpha: 0.9)
        tv.separatorStyle = .singleLine
        tv.separatorColor = .lightGray
        return tv
    }()
    
    let textField: UITextField = {
        let tf = UITextField()
        tf.withImage(direction: .Left, image: UIImage(systemName: "mappin")!, colorSeparator: .clear, colorBorder: .black)
        tf.tintColor = .black
        tf.clearButtonMode = .always
        tf.backgroundColor = UIColor(white: 1, alpha: 0.8)
        return tf
    }()
    
    lazy var backButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "chevron.backward"), for: .normal)
        button.backgroundColor = .clear
        button.addTarget(self, action: #selector(backButtonPressed), for: .touchUpInside)
        button.layer.cornerRadius = 15
        button.clipsToBounds = true
        button.tintColor = .black
        button.layer.shadowColor = UIColor.gray.cgColor
        button.layer.shadowOffset = CGSize(width: 0.0, height: 5.0)
        button.layer.masksToBounds = false
        button.layer.shadowRadius = 2.0
        button.layer.shadowOpacity = 0.5
        return button
    }()
    
    private var suggestionsArray: [SearchSuggestion] = []
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(white: 1, alpha: 1)
        view.addSubview(searchBoxContainerView)
        view.addSubview(tableView)
        
        searchBoxContainerView.addSubview(textField)
        searchBoxContainerView.addSubview(backButton)
        
        searchBoxContainerView.anchor(view.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: view.safeAreaInsets.top + 80, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 120)
        tableView.anchor(searchBoxContainerView.bottomAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        
        backButton.anchor(searchBoxContainerView.topAnchor, left: searchBoxContainerView.leftAnchor, bottom: nil, right: nil, topConstant: 5, leftConstant: 12, bottomConstant: 0, rightConstant: 0, widthConstant: 40, heightConstant: 40)
        textField.anchor(searchBoxContainerView.topAnchor, left: backButton.rightAnchor, bottom: nil, right: searchBoxContainerView.rightAnchor, topConstant: 5, leftConstant: 10, bottomConstant: 0, rightConstant: 16, widthConstant: 0, heightConstant: 40)
        
        tableView.register(SearchResultCell.self, forCellReuseIdentifier: "SearchResultCell")

        
        tableView.dataSource = self
        tableView.delegate = self
        
        searchEngine.delegate = self
                
        textField.delegate = self
        
        textField.addTarget(self, action: #selector(textFieldTextDidChanged), for: .editingChanged)
        
        if (isStartPoint)
        {
            textField.placeholder = "Start"
        }
        else
        {
            textField.placeholder = "End"
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }
    
    @objc func textFieldTextDidChanged() {
        searchEngine.search(query: textField.text!)
    }
    
    @objc func backButtonPressed() {
        remove(frame: view.bounds)
    }
}


extension SearchPointViewController: SearchEngineDelegate {
    func resultResolved(result: MapboxSearch.SearchResult, searchEngine: MapboxSearch.SearchEngine) {
        remove(frame: view.bounds)
        (self.parent as? RideController)?.navigationMapView.mapView.camera.fly(to: .init(center: result.coordinate, zoom: 15), duration: 0.25, completion: nil)
        (self.parent as? RideController)?.endLabel.text = "End 📍 " + result.name
        (self.parent as? RideController)?.requestRouteFor(coordinate: result.coordinate)
        print("Dumping resolved result:", dump(result))
    }
    
    func searchErrorHappened(searchError: MapboxSearch.SearchError, searchEngine: MapboxSearch.SearchEngine) {
        print("Error during search: \(searchError)")
    }
    
    func suggestionsUpdated(suggestions: [SearchSuggestion], searchEngine: SearchEngine) {
        suggestionsArray.removeAll(keepingCapacity: false)
        suggestionsArray.append(contentsOf: suggestions)
        tableView.reloadData()
    }
}

extension SearchPointViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return suggestionsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchResultCell", for: indexPath) as! SearchResultCell
        
        cell.backgroundColor = .clear
        
        let distance = suggestionsArray[indexPath.row].distance?.magnitude ?? 0
        
        let formatter = MeasurementFormatter()

        // Working with meters and evaluating the results
        let distanceInMeters = Measurement(value: distance, unit: UnitLength.meters)
        formatter.unitOptions = .naturalScale
        let finalDistance  = formatter.string(from: distanceInMeters) // prints "2 metres"
        
        cell.configure(title: suggestionsArray[indexPath.row].name, subtitle: finalDistance)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
        
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        view.endEditing(true)        
        searchEngine.select(suggestion: suggestionsArray[indexPath.row])
    }
}


