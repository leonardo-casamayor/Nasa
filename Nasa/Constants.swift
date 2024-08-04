//
//  Constants.swift
//  Nasa
//
//  Created by Leonardo Casamayor on 20/07/2024.
//

import UIKit

struct GeneralConstants {
    static let nasaBlue = UIColor(red:0.02, green:0.24, blue:0.58, alpha:1)
}

struct LoginConstants {
    static let buttonColor = UIColor.white
    static let buttonBorderColor = UIColor(red:0.59, green:0.59, blue:0.59, alpha:1)
    static let segueIdentifier = "loginIdentifier"
    static let userDefaultKey = "isLogin"
    static let errorLoginEmptyField = "Please input your login data"
    static let errorLoginNoUserFound = "Login information does not match"
    static let errorRegisterEmptyField = "Input a username and password to register"
    static let errorRegisterUserExists = "User is already registered"
}

struct NetworkManagerConstants {
    static let apodKey = "11YYA64fHxHGNGEAzR2noyyxRp2SWV2RSCdkOOiA"
    static let apodAPIURL = "https://api.nasa.gov/planetary/apod?api_key=\(NetworkManagerConstants.apodKey)&thumbs=true"
}

struct ApodConstants {
    static let apodMock : APODElement = APODElement(date: "2021-01-01",
                                                    explanation: "The South Celestial Pole is easy to spot in star trail images of the southern sky. The extension of Earth's axis of rotation to the south, it's at the center of all the southern star trail arcs. In this starry panorama streching about 60 degrees across deep southern skies the South Celestial Pole is somewhere near the middle though, flanked by bright galaxies and southern celestial gems. Across the top of the frame are the stars and nebulae along the plane of our own Milky Way Galaxy. Gamma Crucis, a yellowish giant star heads the Southern Cross near top center, with the dark expanse of the Coalsack nebula tucked under the cross arm on the left. Eta Carinae and the reddish glow of the Great Carina Nebula shine along the galactic plane near the right edge. At the bottom are the Large and Small Magellanic clouds, external galaxies in their own right and satellites of the mighty Milky Way. A line from Gamma Crucis through the blue star at the bottom of the southern cross, Alpha Crucis, points toward the South Celestial Pole, but where exactly is it? Just look for south pole star Sigma Octantis. Analog to Polaris the north pole star, Sigma Octantis is little over one degree fom the the South Celestial pole.",
                                                    hdurl: "https://apod.nasa.gov/apod/image/2101/2020_12_16_Kujal_Jizni_Pol_1500px-3.png",
                                                    mediaType: ApodMediaType.image,
                                                    title: "Galaxies and the South Celestial Pole",
                                                    url: "https://apod.nasa.gov/apod/image/2101/2020_12_16_Kujal_Jizni_Pol_1500px-3.jpg",
                                                    copyright: "Mike Smolinsky",
                                                    thumbnailUrl: nil)
}

struct CollectionViewConstants {
    static let conectionError = "There has been an issue reaching the servers"
    static let noResult = "Your search did not match any results"
    static let glass: UIImage? = UIImage(systemName: "magnifyingglass")
    static let wifi: UIImage? = UIImage(systemName: "wifi.slash")
    struct LayoutSize {
        let columns: Int
        let height: CGFloat
    }
}

struct DateFormat {
    static func formatDate(dateString: String) -> String {
        let longDateFormatter = DateFormatter()
        longDateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        if let date = longDateFormatter.date(from: dateString) {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            return dateFormatter.string(from: date)
        } else {
            return dateString
        }
    }
}

struct MediaApiConstants {
    static let mediaAPI: String = "images-api.nasa.gov"
    static let searchEndpoint: String = "/search"
    static let assetEndpoint: String = "/asset/"
    static let metadataEndpoint: String = "/metadata/"
    static let captionEndpoint: String = "/captions/"
    static let albumEndpoint: String = "/album/"
    static let defaultPopularSearch = ["q":"popular",
                                       "media_type":"image,video"]
}

enum DetailType {
    case popularDetail
    case favoriteDetail
}

struct CellDetailConstants {
    //MARK: - Colors
    static let topGradientColor = UIColor(red: 0.04, green: 0.44, blue: 0.78, alpha: 0.07)
    static let bottomGradientColor = UIColor(red: 0.02, green: 0.24, blue: 0.58, alpha: 1)
    static let backgroundColor = CGColor(red: 0.02, green: 0.24, blue: 0.58, alpha: 1)
    
    //MARK: - Images
    static let placeHolderImage = #imageLiteral(resourceName: "PlaceholderCellDetails")
    static let playButton = #imageLiteral(resourceName: "PlayButton")
    static let crossMark = "xmark"
    static let favHeartOutline = "suit.heart"
    static let favHeartFill = "suit.heart.fill"
    
    //MARK: - Size Modifiers
    static let rectPaddingMod: CGFloat = 0.1
    static let rectRadius: CGFloat = 4
    static let imageHeightModifier: CGFloat = 0.39
    static let imageHeightModifierPad: CGFloat = 0.425
    static let playHeightMod: CGFloat = 0.15
    static let playWidthMod: CGFloat = 0.25
    static let playPadMod: CGFloat = 0.12
    static let widthConstraint: CGFloat = 0.93
    static let textTopPadding: CGFloat = 0.12
    static let halfScreen: CGFloat = 0.5
    static let cornerRadius: CGFloat = 10

    //MARK: - Fonts
    static let fontCompactTitle: UIFont = UIFont (name: "HelveticaNeue-Medium", size: 20)!
    static let fontCompactText: UIFont = UIFont (name: "HelveticaNeue-Medium", size: 17)!
    static let fontRegularTitle: UIFont = UIFont (name: "HelveticaNeue-Medium", size: 26)!
    static let fontRegularText: UIFont = UIFont (name: "HelveticaNeue-Medium", size: 23)!
    
    
    //MARK: - Strings
    static let storyboardID = "Main"
    static let videoPlayerID = "VideoPlayer"
    static let navTitle = "VideoTitleGoesHere"
    static let title = "Title, and date goes here"
    static let implementMe = "Implement Favorite button function here"
    static let mockText = "Contrary to popular belief, Lorem Ipsum is not simply random text. It has roots in a piece of classical Latin literature from 45 BC, making it over 2000 years old. Richard McClintock, a Latin professor at Hampden-Sydney College in Virginia, looked up one of the more obscure Latin words, consectetur, from a Lorem Ipsum passage, and going through the cites of the word in classical literature, discovered the undoubtable source. Lorem Ipsum comes from sections 1.10.32 and 1.10.33 of de Finibus Bonorum et Malorum (The Extremes of Good and Evil) by Cicero, written in 45 BC. This book is a treatise on the theory of ethics, very popular during the Renaissance. The first line of Lorem Ipsum, Lorem ipsum dolor sit amet.., comes from a line in section 1.10.32.he standard chunk of Lorem Ipsum used since the 1500s is reproduced below for those interested. Sections 1.10.32 and 1.10.33 from de Finibus Bonorum et Malorum by Cicero are also reproduced in their exact original form, accompanied by English versions from the 1914 translation by H. Rackham.Contrary to popular belief, Lorem Ipsum is not simply random text. It has roots in a piece of classical Latin literature from 45 BC, making it over 2000 years old. Richard McClintock, a Latin professor at Hampden-Sydney College in Virginia, looked up one of the more obscure Latin words, consectetur, from a Lorem Ipsum passage, and going through the cites of the word in classical literature, discovered the undoubtable source. Lorem Ipsum comes from sections 1.10.32 and 1.10.33 of de Finibus Bonorum et Malorum (The Extremes of Good and Evil) by Cicero, written in 45 BC. This book is a treatise on the theory of ethics, very popular during the Renaissance. The first line of Lorem Ipsum, Lorem ipsum dolor sit amet.., comes from a line in section 1.10.32.he standard chunk of Lorem Ipsum used since the 1500s is reproduced below for those interested. Sections 1.10.32 and 1.10.33 from de Finibus Bonorum et Malorum by Cicero are also reproduced in their exact original form, accompanied by English versions from the 1914 translation by H. Rackham.Contrary to popular belief, Lorem Ipsum is not simply random text. It has roots in a piece of classical Latin literature from 45 BC, making it over 2000 years old. Richard McClintock, a Latin professor at Hampden-Sydney College in Virginia, looked up one of the more obscure Latin words, consectetur, from a Lorem Ipsum passage, and going through the cites of the word in classical literature, discovered the undoubtable source. Lorem Ipsum comes from sections 1.10.32 and 1.10.33 of de Finibus Bonorum et Malorum (The Extremes of Good and Evil) by Cicero, written in 45 BC. This book is a treatise on the theory of ethics, very popular during the Renaissance. The first line of Lorem Ipsum, Lorem ipsum dolor sit amet.., comes from a line in section 1.10.32.he standard chunk of Lorem Ipsum used since the 1500s is reproduced below for those interested. Sections 1.10.32 and 1.10.33 from de Finibus Bonorum et Malorum by Cicero are also reproduced in their exact original form, accompanied by English versions from the 1914 translation by H. Rackham.Contrary to popular belief, Lorem Ipsum is not simply random text. It has roots in a piece of classical Latin literature from 45 BC, making it over 2000 years old. Richard McClintock, a Latin professor at Hampden-Sydney College in Virginia, looked up one of the more obscure Latin words, consectetur, from a Lorem Ipsum passage, and going through the cites of the word in classical literature, discovered the undoubtable source. Lorem Ipsum comes from sections 1.10.32 and 1.10.33 of de Finibus Bonorum et Malorum (The Extremes of Good and Evil) by Cicero, written in 45 BC. This book is a treatise on the theory of ethics, very popular during the Renaissance. The first line of Lorem Ipsum, Lorem ipsum dolor sit amet.., comes from a line in section 1.10.32.he standard chunk of Lorem Ipsum used since the 1500s is reproduced below for those interested. Sections 1.10.32 and 1.10.33 from de Finibus Bonorum et Malorum by Cicero are also reproduced in their exact original form, accompanied by English versions from the 1914 translation by H. Rackham.Contrary to popular belief, Lorem Ipsum is not simply random text. It has roots in a piece of classical Latin literature from 45 BC, making it over 2000 years old. Richard McClintock, a Latin professor at Hampden-Sydney College in Virginia, looked up one of the more obscure Latin words, consectetur, from a Lorem Ipsum passage, and going through the cites of the word in classical literature, discovered the undoubtable source. Lorem Ipsum comes from sections 1.10.32 and 1.10.33 of de Finibus Bonorum et Malorum (The Extremes of Good and Evil) by Cicero, written in 45 BC. This book is a treatise on the theory of ethics, very popular during the Renaissance. The first line of Lorem Ipsum, Lorem ipsum dolor sit amet.., comes from a line in section 1.10.32.he standard chunk of Lorem Ipsum used since the 1500s is reproduced below for those interested. Sections 1.10.32 and 1.10.33 from de Finibus Bonorum et Malorum by Cicero are also reproduced in their exact original form, accompanied by English versions from the 1914 translation by H. Rackham.Contrary to popular belief, Lorem Ipsum is not simply random text. It has roots in a piece of classical Latin literature from 45 BC, making it over 2000 years old. Richard McClintock, a Latin professor at Hampden-Sydney College in Virginia, looked up one of the more obscure Latin words, consectetur, from a Lorem Ipsum passage, and going through the cites of the word in classical literature, discovered the undoubtable source. Lorem Ipsum comes from sections 1.10.32 and 1.10.33 of de Finibus Bonorum et Malorum (The Extremes of Good and Evil) by Cicero, written in 45 BC. This book is a treatise on the theory of ethics, very popular during the Renaissance. The first line of Lorem Ipsum, Lorem ipsum dolor sit amet.., comes from a line in section 1.10.32.he standard chunk of Lorem Ipsum used since the 1500s is reproduced below for those interested. Sections 1.10.32 and 1.10.33 from de Finibus Bonorum et Malorum by Cicero are also reproduced in their exact original form, accompanied by English versions from the 1914 translation by H. Rackham."
}

struct AlertConstants {
    static let favoritesAlertTitle = "Favorite could not be saved"
    static let favoritesAlertMessage = "There was an error saving the data"
}

struct VideoPlayerConstants {
    static let videoUrl = "https://images-assets.nasa.gov/video/NHQ_2014_1010_TWAN/NHQ_2014_1010_TWAN~mobile.mp4"
    static let duration = "duration"
    static let hoursFormat = "%i:%02i:%02i"
    static let minutesFormat = "%02i:%02i"
    static let bigIpad: CGFloat = 1200.00
    static let mediumIpad: CGFloat = 1000.00
    static let verticalSmallPad: CGFloat = 750.00
    static let bigIhpone: CGFloat = 897.00
    static let distanceToPlay: CGFloat = 0.1
    static let bigHeightMod: CGFloat = 0.1
    static let smallHeightMod: CGFloat = 0.14
}

extension UIImage {
    static let muted: UIImage? = UIImage(systemName: "volume.slash.fill")
    static let unmuted: UIImage? = UIImage(systemName: "volume.fill")
    static let play: UIImage? = UIImage(systemName: "play.circle.fill")
    static let pause: UIImage? = UIImage(systemName: "pause.circle.fill")
    static let replay: UIImage? = UIImage(systemName: "arrow.uturn.left")
}
