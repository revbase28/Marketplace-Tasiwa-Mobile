import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

//Change the icons as your app needs
IconData getCategoryIcon(String? iconString) {
  switch (iconString) {
    case 'fa-shower':
      return FontAwesomeIcons.shower;
    case 'fa-plug':
      return FontAwesomeIcons.plug;
    case 'fa-gamepad':
      return FontAwesomeIcons.gamepad;
    case 'fa-tshirt':
      return FontAwesomeIcons.tshirt;
    case 'fa-hot-tub':
      return FontAwesomeIcons.hotTub;
    case 'fa-skiing':
      return FontAwesomeIcons.skiing;
    case 'fa-gem':
      return FontAwesomeIcons.gem;
    case 'fa-dog':
      return FontAwesomeIcons.dog;
    case 'fa-paint-brush':
      return FontAwesomeIcons.paintBrush;
    case 'fa-beer':
      return FontAwesomeIcons.beer;
    case 'fa-glass':
      return FontAwesomeIcons.wineGlass;
    case 'fa-car':
      return FontAwesomeIcons.car;
    case 'fa-plane':
      return FontAwesomeIcons.plane;
    case 'fa-bicycle':
      return FontAwesomeIcons.bicycle;
    case 'fa-motorcycle':
      return FontAwesomeIcons.motorcycle;
    case 'fa-truck':
      return FontAwesomeIcons.truck;
    case 'fa-bus':
      return FontAwesomeIcons.bus;
    case 'fa-train':
      return FontAwesomeIcons.train;
    case 'fa-subway':
      return FontAwesomeIcons.subway;
    case 'fa-briefcase':
      return FontAwesomeIcons.briefcase;
    case 'fa-suitcase':
      return FontAwesomeIcons.suitcase;
    case 'fa-shopping-bag':
      return FontAwesomeIcons.shoppingBag;
    case 'fa-shopping-cart':
      return FontAwesomeIcons.shoppingCart;
    case 'fa-umbrella':
      return FontAwesomeIcons.umbrella;
    case 'fa-umbrella-beach':
      return FontAwesomeIcons.umbrellaBeach;
    case 'fa-bed':
      return FontAwesomeIcons.bed;
    case 'fa-utensils':
      return FontAwesomeIcons.utensils;
    case 'fa-carrot':
      return FontAwesomeIcons.carrot;
    case 'fa-wine-glass':
      return FontAwesomeIcons.wineGlass;
    case 'fa-glass-martini':
      return FontAwesomeIcons.glassMartini;
    case 'fa-glass-martini-alt':
      return FontAwesomeIcons.glassMartiniAlt;
    case 'fa-glass-whiskey':
      return FontAwesomeIcons.glassWhiskey;
    case 'fa-glass-cheers':
      return FontAwesomeIcons.glassCheers;
    case 'fa-bitbucket':
      return FontAwesomeIcons.glassWhiskey;
    default:
      return FontAwesomeIcons.cubes;
  }
}
