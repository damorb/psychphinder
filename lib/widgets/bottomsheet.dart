import 'package:flutter/material.dart';
import 'package:flutter_list_view/flutter_list_view.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:psychphinder/classes/phrase_class.dart';
import 'package:psychphinder/global/globals.dart';

class BottomSheetEpisode extends StatefulWidget {
  const BottomSheetEpisode({
    super.key,
    required this.indexLine,
    required this.fullEpisode,
    required this.phrase,
    required this.referencesList,
  });

  final int indexLine;
  final List fullEpisode;
  final Phrase phrase;
  final List referencesList;

  @override
  State<BottomSheetEpisode> createState() => _BottomSheetEpisodeState();
}

class _BottomSheetEpisodeState extends State<BottomSheetEpisode> {
  int currentRef = 0;
  List<String> referenceSearch(List referenceData) {
    List<String> referenceSelected = [];
    for (var i = 0; i < referenceData.length; i++) {
      final id = referenceData[i].id.replaceAll('\r', '').trim();
      final idPhrase = widget.phrase.reference.replaceAll('\r', '').trim();
      final splitted = idPhrase.split(',');
      for (var j = 0; j < splitted.length; j++) {
        if (id == splitted[j]) {
          referenceSelected.add(referenceData[i].reference);
        }
      }
    }
    return referenceSelected;
  }

  int findIndex(List fullEpisode, int referenceId) {
    int index = 0;
    for (var i = 0; i < fullEpisode.length; i++) {
      if (fullEpisode[i].id == referenceId) {
        index = i;
        return index;
      }
    }
    return index;
  }

  @override
  Widget build(BuildContext context) {
    var csvData = Provider.of<CSVData>(context);
    final List referenceData = csvData.referenceData;

    FlutterListViewController controller = FlutterListViewController();
    return ValueListenableBuilder(
      valueListenable: Hive.box("favorites").listenable(),
      builder: (BuildContext context, dynamic box, Widget? child) {
        final isFavorite = widget.referencesList.isEmpty
            ? box.get(widget.phrase.id) != null
            : box.get(int.parse(widget.referencesList[currentRef])) != null;
        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                widget.referencesList.length > 19
                    ? Expanded(flex: 1, child: Container())
                    : const SizedBox(width: 0),
                Expanded(
                  flex: 8,
                  child: Center(
                    child: Column(
                      children: [
                        Text(
                          widget.phrase.name,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'PsychFont'),
                        ),
                        if (widget.phrase.season != 0)
                          Text(
                            "Season ${widget.phrase.season}, Episode ${widget.phrase.episode}",
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 15,
                                // fontWeight: FontWeight.bold,
                                fontStyle: FontStyle.italic,
                                fontFamily: 'PsychFont'),
                          ),
                      ],
                    ),
                  ),
                ),
                widget.referencesList.length > 1
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.arrow_circle_left,
                              size: 25,
                            ),
                            onPressed: () {
                              if (currentRef > 0) {
                                int referenceId = findIndex(
                                    widget.fullEpisode,
                                    int.parse(
                                        widget.referencesList[currentRef - 1]));
                                if (referenceId >= 3) {
                                  controller.sliverController
                                      .jumpToIndex(referenceId - 3);
                                } else {
                                  controller.sliverController
                                      .jumpToIndex(referenceId);
                                }
                                currentRef--;
                                setState(() {
                                  currentRef;
                                });
                              }
                            },
                          ),
                          Text(
                            "${currentRef + 1}/${widget.referencesList.length}",
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                            ),
                          ),
                          IconButton(
                              icon: const Icon(
                                Icons.arrow_circle_right,
                                size: 25,
                              ),
                              onPressed: () {
                                if (currentRef <
                                    widget.referencesList.length - 1) {
                                  int referenceId = findIndex(
                                      widget.fullEpisode,
                                      int.parse(widget
                                          .referencesList[currentRef + 1]));
                                  if (referenceId >= 3) {
                                    controller.sliverController
                                        .jumpToIndex(referenceId - 3);
                                  } else {
                                    controller.sliverController
                                        .jumpToIndex(referenceId);
                                  }
                                  currentRef++;
                                  setState(() {
                                    currentRef;
                                  });
                                }
                              })
                        ],
                      )
                    : const SizedBox(),
              ],
            ),
            Expanded(
              child: FlutterListView(
                controller: controller,
                delegate: FlutterListViewDelegate(
                  (BuildContext context, int index) {
                    final hasReference = widget.phrase.reference.contains("s");
                    if (widget.referencesList.isEmpty) {
                      if (widget.indexLine == index) {
                        return ListTile(
                          title: Text(
                            "${widget.fullEpisode[index].time}   ${widget.fullEpisode[index].line}",
                            style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.green),
                          ),
                          trailing: hasReference
                              ? IconButton(
                                  onPressed: () {
                                    final selectedReference =
                                        referenceSearch(referenceData);
                                    showDialog<String>(
                                      context: context,
                                      builder: (BuildContext context) =>
                                          AlertDialog(
                                        backgroundColor: Colors.green,
                                        title: const Text(
                                          'This is a reference to',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontFamily: 'PsychFont',
                                              fontWeight: FontWeight.bold),
                                        ),
                                        content: selectedReference.length > 1
                                            ? Column(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  for (var i = 0;
                                                      i <
                                                          selectedReference
                                                              .length;
                                                      i++) ...[
                                                    Text(
                                                      selectedReference[i],
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 10),
                                                  ],
                                                ],
                                              )
                                            : Text(
                                                selectedReference.first,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.question_mark_rounded),
                                  color: Colors.green,
                                )
                              : null,
                        );
                      } else {
                        return ListTile(
                          title: Text(
                            "${widget.fullEpisode[index].time}   ${widget.fullEpisode[index].line}",
                          ),
                        );
                      }
                    } else {
                      int referenceId = findIndex(widget.fullEpisode,
                          int.parse(widget.referencesList[currentRef]));
                      if (referenceId == index) {
                        return ListTile(
                          title: Text(
                            "${widget.fullEpisode[index].time}   ${widget.fullEpisode[index].line}",
                            style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.green),
                          ),
                          trailing: hasReference
                              ? IconButton(
                                  onPressed: () {
                                    final selectedReference =
                                        referenceSearch(referenceData);
                                    showDialog<String>(
                                      context: context,
                                      builder: (BuildContext context) =>
                                          AlertDialog(
                                        backgroundColor: Colors.green,
                                        title: const Text(
                                          'This is a reference to',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontFamily: 'PsychFont',
                                              fontWeight: FontWeight.bold),
                                        ),
                                        content: selectedReference.length > 1
                                            ? Column(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  for (var i = 0;
                                                      i <
                                                          selectedReference
                                                              .length;
                                                      i++) ...[
                                                    Text(
                                                      selectedReference[i],
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 10),
                                                  ],
                                                ],
                                              )
                                            : Text(
                                                selectedReference.first,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.question_mark_rounded),
                                  color: Colors.green,
                                )
                              : null,
                        );
                      } else {
                        return ListTile(
                          title: Text(
                            "${widget.fullEpisode[index].time}   ${widget.fullEpisode[index].line}",
                          ),
                        );
                      }
                    }
                  },
                  childCount: widget.fullEpisode.length,
                  initIndex: widget.indexLine - 3,
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: ElevatedButton(
                onPressed: () async {
                  // if (!isFavorite) {
                  //   await box.put(widget.phrase.id, widget.phrase);
                  // } else {
                  //   await box.delete(widget.phrase.id);
                  // }
                  if (widget.referencesList.isEmpty) {
                    if (!isFavorite) {
                      await box.put(widget.phrase.id, widget.phrase);
                    } else {
                      await box.delete(widget.phrase.id);
                    }
                  } else {
                    int referenceId = findIndex(widget.fullEpisode,
                        int.parse(widget.referencesList[currentRef]));
                    if (!isFavorite) {
                      await box.put(
                          int.parse(widget.referencesList[currentRef]),
                          widget.fullEpisode[referenceId]);
                    } else {
                      await box
                          .delete(int.parse(widget.referencesList[currentRef]));
                    }
                  }
                },
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(
                  Colors.green,
                )),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(isFavorite
                        ? 'Remove from favorites'
                        : 'Add to favorites'),
                    const Icon(
                      Icons.favorite,
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
