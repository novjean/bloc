import 'package:bloc/db/entity/party_guest.dart';
import 'package:flutter/material.dart';

import '../../db/entity/promoter.dart';
import '../../main.dart';
import '../ui/textfield_widget.dart';

class PartyGuestWidget extends StatefulWidget {
  PartyGuest partyGuest;
  List<Promoter> promoters;

  PartyGuestWidget({Key? key, required this.partyGuest, required this.promoters}) : super(key: key);

  @override
  State<PartyGuestWidget> createState() => _PartyGuestWidgetState();
}

class _PartyGuestWidgetState extends State<PartyGuestWidget> {
  String sGender = 'male';
  List<String> genders = [
    'male',
    'female',
    'transgender',
    'non-binary/non-conforming',
    'prefer not to respond'
  ];

  List<Promoter> mPromoters = [];
  List<String> mPromoterNames = [''];
  String sPromoterName = '';
  String sPromoterId = '';

  @override
  void initState() {
    sGender = widget.partyGuest.gender;

    if (widget.partyGuest.promoterId.isNotEmpty) {
      sPromoterId = widget.partyGuest.promoterId;
    } else {
      sPromoterId = '';
      sPromoterName = mPromoterNames.first;
    }

    for(Promoter promoter in widget.promoters){
      mPromoterNames.add(promoter.name);
      if(promoter.id == sPromoterId){
        sPromoterName = promoter.name;
      }
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
            height: mq.height * 0.7,
            width: mq.width * 0.8,
            child: ListView(
              physics: const BouncingScrollPhysics(),
              children: [
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: TextFieldWidget(
                    label: 'name *',
                    text: widget.partyGuest.name,
                    onChanged: (text) {
                      widget.partyGuest =
                          widget.partyGuest.copyWith(name: text);
                    },
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: TextFieldWidget(
                    label: 'surname',
                    text: widget.partyGuest.surname,
                    onChanged: (text) {
                      widget.partyGuest =
                          widget.partyGuest.copyWith(surname: text);
                    },
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: TextFieldWidget(
                    label: 'phone',
                    text: widget.partyGuest.phone,
                    onChanged: (text) {
                      widget.partyGuest =
                          widget.partyGuest.copyWith(phone: text);
                    },
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              'gender',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      FormField<String>(
                        builder: (FormFieldState<String> state) {
                          return InputDecorator(
                            key: const ValueKey('gender_dropdown'),
                            decoration: InputDecoration(
                                fillColor: Colors.white,
                                errorStyle: TextStyle(
                                    color: Theme.of(context).errorColor,
                                    fontSize: 16.0),
                                hintText: 'please select gender',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5.0),
                                  borderSide: const BorderSide(),
                                ),
                                enabledBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(width: 0.0),
                                )),
                            isEmpty: sGender == '',
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                // dropdownColor: Constants.background,
                                value: sGender,
                                isDense: true,
                                onChanged: (String? newValue) {
                                  setState(() {
                                    sGender = newValue!;

                                    widget.partyGuest = widget.partyGuest
                                        .copyWith(gender: sGender);
                                    state.didChange(newValue);
                                  });
                                },
                                items: genders.map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              'promoter',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      FormField<String>(
                        builder: (FormFieldState<String> state) {
                          return InputDecorator(
                            key: const ValueKey('promoter_dropdown'),
                            decoration: InputDecoration(
                                fillColor: Colors.white,
                                errorStyle: TextStyle(
                                    color: Theme.of(context).errorColor,
                                    fontSize: 16.0),
                                hintText: 'please select a promoter',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5.0),
                                  borderSide: const BorderSide(),
                                ),
                                enabledBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(width: 0.0),
                                )),
                            isEmpty: sPromoterName == '',
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                // dropdownColor: Constants.background,
                                value: sPromoterName,
                                isDense: true,
                                onChanged: (String? newValue) {
                                  setState(() {
                                    sPromoterName = newValue!;

                                    if(sPromoterName.isEmpty){
                                      sPromoterId='';
                                    } else {
                                      for (Promoter promoter in widget.promoters) {
                                        if (promoter.name == sPromoterName) {
                                          sPromoterId = promoter.id;
                                          break;
                                        }
                                      }
                                    }

                                    widget.partyGuest = widget.partyGuest
                                        .copyWith(promoterId: sPromoterId);
                                    state.didChange(newValue);
                                  });
                                },
                                items: mPromoterNames.map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
  }
}
