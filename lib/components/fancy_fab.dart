import 'package:flutter/material.dart';

class FancyFab extends StatefulWidget {
  final Function() onPressed;
  final String tooltip;
  final IconData icon;
  FancyFab({this.icon, this.onPressed, this.tooltip});
  @override
  _FancyFabState createState() => _FancyFabState();
}

class _FancyFabState extends State<FancyFab> with SingleTickerProviderStateMixin {
  bool isOpened = false;
  AnimationController _animationController;
  Animation<Color> _animateColor;
  Animation<double> _animateIcon;
  Animation<double> _translateButton;
  Curve _curve = Curves.easeOut;
  double _fabHeight = 56.0;

  @override
  void initState() {
    _animationController = AnimationController(vsync: this, duration: Duration(milliseconds: 500))..addListener((){ setState(() {}); });
    _animateIcon = Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    _animateColor = ColorTween(begin: Color(0xff76BD21), end: Color(0xff76BD21)).animate(CurvedAnimation(parent: _animationController, curve: Interval(0.00, 1.00, curve: Curves.linear)));
    _translateButton = Tween<double>(begin: _fabHeight, end: -14.0).animate(CurvedAnimation(parent: _animationController, curve: Interval(0.0, 0.75, curve: _curve)));
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  animate(){
    if(!isOpened){
      _animationController.forward();
    }else{
      _animationController.reverse();
    }
    isOpened = !isOpened;
  }

  Widget add(){
    return new Container(
      child: FloatingActionButton(
        heroTag: "btn3",
        onPressed: null,
        tooltip: 'Agregar Integrante',
        child: Icon(Icons.person_add),
        backgroundColor: Color(0xff76BD21),
      )
    );
  }

  Widget image(){
    return Container(
      child: FloatingActionButton(
        heroTag: "btn2",
        onPressed: null,
        tooltip: 'Cerrar Grupo',
        child: Icon(Icons.lock),
        backgroundColor: Color(0xff76BD21),
      ),
    );
  }

  Widget toggle(){
    return Container(child: FloatingActionButton(
      heroTag: "btn1",
      backgroundColor: _animateColor.value,
      onPressed: animate,
      tooltip: 'Toggle',
      child: AnimatedIcon(icon: AnimatedIcons.menu_close, progress: _animateIcon),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Transform(
          transform: Matrix4.translationValues(0.0, _translateButton.value * 2.0, 0.0),
          child: add(),
        ),
        Transform(
          transform: Matrix4.translationValues(0.0, _translateButton.value * 1.0, 0.0),
          child: image(),
        ),
        toggle()
      ]
    );
  }
}