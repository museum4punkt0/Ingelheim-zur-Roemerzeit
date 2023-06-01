# Ingelheim zur Römerzeit App 
# Kurzbeschreibung 
Die App „Ingelheim zur Römerzeit“ verknüpft Objekte aus dem Museum bei der Kaiserpfalz mit ihren Fundorten. Durch 360°-Panoramen in Augmented Reality, Videos und Bilder wird die römische Lebenswelt des 1. Jahrhunderts n. Chr. im Raum Ingelheim erlebbar gemacht. 
Inhaltlicher Höhepunkt der App ist die Darstellung eines monumentalen Grabdenkmals mit drei Grabfiguren, die Ende des 19. Jahrhunderts nördlich von Ingelheim gefunden wurden.  

Durch 3D-Scans wurden diese Figuren dreidimensional und farbig rekonstruiert und in ein 360°-Panorama eingebettet. So kann das einstige Monument, von dem selbst nichts erhalten ist, in seiner ursprünglichen Umgebung betrachtet werden.  

Die Stifterin des Grabmonuments kann über einen Hotspot Button ausgewählt werden. Sie erzählt den App-Nutzer/innen aus ihrem Leben und vermittelt einen spannenden Einblick in die Gesellschaft zur Römerzeit.
# Aufteilung
Dieses Repository gibt Informationen zur Programmierung der Funktion "Aufruf 360 Grad Panorama" in der App Ingelheim zur Römerzeit. Hervorzuheben ist hierbei, dass die App beim Öffnen des 360 Grad Panoramas vor Ort anhand der Kompassdaten des Smartphones / Tablets den Blickwinkel der Nutzer/innen erkennt und automatisch den zum Blickwinkel passenden Ausschnitt des 360° Panoramas anzeigt. 
# Entstehungskontext & Förderhinweis
Die native App Ingelheim zur Römerzeit auf Basis des Future History Frameworks ist entstanden im Verbundprojekt museum4punkt0 – Digitale Strategien für das Museum der Zukunft, Teilprojekt AR-Panoramen – Mit dem Smartphone in die Römerzeit. Das Projekt museum4punkt0 wird gefördert durch die Beauftragte der Bundesregierung für Kultur und Medien aufgrund eines Beschlusses des Deutschen Bundestages. Weitere Informationen: https://www.museum4punkt0.de   

Das Verbundprojekt museum4punkt0 wird geleitet und koordiniert von der Stiftung Preußischer Kulturbesitz.

# Dokumentation der Programmierung
Die technische Entwicklung der Funktion "Aufruf 360 Grad Panorama" erfolgte nativ in den Programmiersprachen SWIFT für die iOS Version sowie Kotlin für die Android Version. Diese Funktion ist eingebettet in die Codebasis der unter dem Markennamen "Future History" in mehrjähriger Entwicklungsarbeit entstandenen Technologie (Webportal: http://www.future-history.eu, Play Store / App Store: Future History APP). Aus dieser Codebasis wurden die Tour Detailansicht zum Start der Tour, die Kartenansicht zur Selektion und zum Aufruf einer Station, die Navigation zum Zielpunkt sowie die Stationsdetailansicht übernommen und optisch auf das Corporate Design des Museums bei der Kaiserpfalz und der Stadt Ingelheim angepasst. Weitere wichtige Funktionen der App wie Offline-Funktionalität und Mehrsprachigkeit wurden ebefalls aus der vorhandenen Codebasis übernommen. Somit konnte die App Ingelheim zur Römerzeit unter Berücksichtigung des vorhandenen Budgets mit einer großen Funktionsvielfalt und dennoch zu einem sehr wirtschaftlichen Preis erstellt werden.  

Tutorial Screens zur Einführung in die Benutzung, Logo-Elemente, rechtliche Bestimmungen, App-Icon und Preview-Screens für den Apple App Store und Google Play Store wurden individuell für das Projekt erstellt und eingefügt. Ebenso wurde die Kernfunktion der Ingelheim zur Römerzeit App "Aufruf 360 Grad Panorama" individuell für das Projekt als Modul entwickelt. Der Code dieses Moduls ist im Github Ordner zu diesem Projekt als Version für Android und iOS veröffentlicht.
Die im Google Play Store unter https://play.google.com/store/apps/details?id=com.extendedvision.futurehistory.ingelheim sowie im Apple App Store unter https://apps.apple.com/de/app/ingelheim-zur-r%C3%B6merzeit/id1645512736 aufrufbare Live-Version der App ruft sämtliche Inhalte aus der Datenbank eines Webservers auf. Diese Datenbankinhalte können vom Museum bei der Kaiserpfalz über ein Redaktionssystem (technische Basis: Drupal) gepflegt, aktualisiert und jederzeit um weitere Stationen ergänzt werden.  

Da wir Ihnen in diesem Github Repository ein einfach installierbares und sofort lauffähiges Modul zur Ansicht von 360 Grad Panoramen vor Ort unter Berücksichtigung des realen Blickwinkels der Nutzer/innen beim initialen Öffnen des 360 Grad Panoramas bereitstellen möchten, haben wir den im Repository enthaltenen Code so angepasst, dass er ohne Installation eines Webservers direkt auf die ebenfalls im Repository vorhandenen Inhalte lokal zugreifen kann.   
# Modul "Aufruf 360 Grad Panorama" 
Das Module beinhaltet die folgenden Funktionen:
- initaler Aufruf des 360 Grad Panoramas: anhand der Kompassdaten des Smartphones / Tablets wird nach dem Öffnen des 360 Grad Panoramas vor Ort der reale Blickwinkel der Nutzer/innen erkannt und automatisch der zum Blickwinkel passende Ausschnitt des 360° Panoramas angezeigt. Die Vorgaben an die 360° Panorama Bilddatei lauten hierbei, dass die Visualisierung der römischen Lebenswelt exakt in der Bildmitte die Szenerie nach Norden zeigen muss, während an den Bildrändern die Szenerie in südlicher Blickrichtung gezeigt wird. Ebenso wird beim Aufruf des 360 Grad Panoramas die vertikale Ausrichtung (Zenith, Horizont, Nadir) über das Gyroskop gemessen und der passende vertikale Bildausschnitt des 360 Grad Panoramas angezeigt (Himmel, Horizont, Boden)  
- Änderungen des Blickwinkels, Dreh-, Kipp- und Neigebewegungen des Mobilgerätes durch Besucher/innen werden über den Gyroskop-Sensor in Echtzeit verarbeitet und ändern den im 360 Grad Panorama angezeigten Bildausschnitt.
- Hotspot zum Aufruf von eingebetteten Objekten wie z.B. Videos: Charaktere und Handlungen werden in geeignete Bereiche des 360 Grad Panoramas eingebunden und nach Antippen  einer „Hotspot Verlinkung“ startet das Video der Stifterin des Grabdenkmals im 360 Grad Panorama. Sie bewegt sich in einer Videosequenz auf die Nutzer/innen zu, um diesen spannende Einblicke aus ihrem Leben und ihrer Zeit zu vermitteln. Technisch erfolgt die Positionierung der Hotspot Verlinkung im 360 Grad Panorama über die X / Y Koordinaten des Bildpunktes. In der in den Stores produktiven App Version können die X / Y Koordinaten zur exakten Definition der Position einer Hotspot Verlinkung über das Redaktionssystem eingegeben werden. Der im Repository enthaltene Code besitzt eine feste X / Y Koordinate zur Einblendung des "Hotspot Buttons" im 360 Grad Panorama.  
# Installation
Lauffähig ist die Ingelheim zur Römerzeit App auf Smartphones und Tablets mit iOS oder Android Betriebssystem. Hardware Modelle von 2015 oder neuer werden uneingeschränkt ab den Versionen Android 6 und IOS 13 unterstützt. Nach dem Stand bei Veröffentlichtung der App im April 2023 umfasst dies über 98% aller Smartphone und Tablet Nutzer. 
Sowohl über die Direktsuche im App Store und Play Store als auch über QR-Codes (zwei unterschiedliche QR-Codes für die App-Store und Play-Store Version) können Nutzer/innen die App schnell und problemlos installieren. Die Darstellung der Inhalte erfolgt angepasst auf die Größe der Ausgabegeräte.   
# Benutzung der Ingelheim zur Römerzeit App
- Start/Ladeansicht: Nach Start der App öffnet diese während des Ladevorgangs mit einem Startscreen, welcher das Logo des Museums bei der Kaiserpfalz sowie das Logo der Stadt Ingelheim beinhaltet.
- App-Oberfläche und Inhalte werden entsprechend der Spracheinstellung der Nutzer/innen nach der App-Installation in deutscher oder englischer Sprache angezeigt. Die Sprach¬einstellung kann im Seitenmenu nachträglich jederzeit geändert werden.
- Tutorial Screens zur Einführung: In den sechs Tutorial Screens wird die grundsätzliche Funktionsweise der App beschrieben. Die Bildmotive der Tutorial Screens weisen bereits auf inhaltliche Highlights der App hin, um den Appetit der Nutzer/innen auf die weitere Erkundung der App Inhalte und Funktionen nach Installation anzuregen.
- Einholung der Zustimmung zur Datenschutzerklärung: In diesem Screen können Nutzer/innen die Datenschutzbestimmungen und Nutzungsbedingungen der App einsehen und werden um Zustimmung zu den Datenschutzbestimmungen gebeten. Optional können Nutzer/innen das App Tracking zu Zwecken der Produktverbesserung und -analyse erteilen. Im Standard ist das App Tracking deaktiviert. Die in diesem Screen vorgenommenen Einstellungen können später im Seitenmenu jederzeit nachträglich angepasst werden.
- Tour Detailansicht / Stationsüberblick: Dieser Screen enthält Titel, Beschreibung und Dauer der Tour sowie die Länge der Wegstrecke und eine Übersicht der enthaltenen Stationen, an denen die Inhalte vor Ort auf Smartphone und Tablet der Besucher eingeblendet werden können. Aus dem Stationsüberblick können App-Nutzer/innen entweder direkt fortfahren oder sämtliche Inhalte vorab auf das lokale Gerät (Smartphone / Tablet) herunterladen, bevor der Kartenscreen über „TOUR STARTEN“ aufgerufen wird.
-  Kartenansicht: Die Kartenansicht zeigt die enthaltenen Stationen als Kartenpunkte auf einer Google Maps Karte. In der rechten Spalte werden die Miniaturbilder zu den Stationen aufgelistet in der empfohlenen Reihenfolge, beginnend mit der ersten Station der Tour. Über Antippen eines Kartenpunktes oder Miniaturbildes wird die entsprechende Station selektiert. GPS-Ortung und Routenführung bringen den Nutzer zielsicher zur ausgewählten Station. 
-  Stationsdetail Ansicht: An der Station angelangt wird per GPS gesteuert automatisch die Stationsdetail Ansicht geöffnet. App-Nutzerinnen können diese Ansicht auch direkt aus der Kartenansicht auswählen (ohne vor Ort zu sein), um zu Hause, im Hotel oder der Ferienwohnung den Besuch der Stationen über die App vorzubereiten und Vorfreude auf den Aufenthalt zu entwickeln. Neben der Einblendung der römischen Lebenswelt im 360° Panorama mit den rekonstruierten Grabfiguren können an den einzelnen Stationen über Buttons in der unteren Menuleiste Audiodateien, Texte und Videos aufgerufen werden. Auch die Einblendung des Bildmaterials in die Smartphone Kamera im passenden Blickwinkel sowie die Überblendung mit der Realität (Augmented Reality) erfolgt über den "Auge Button" in der unteren Menuleiste.   
-  Seitenmenu: die einführenden Tutorial Screens können nachträglich über das Seitenmenu wieder aufgerufen werden. Die Erlaubnis zum App-Tracking kann ferner über die Einstellungen nachträglich entzogen oder erteilt werden und die bei der App-Installation automatisch zugewiesene Sprache kann hier manuell umgestellt werden. Rechtliche Informationen zur App wie Impressum, Datenschutzbestimmungen und Nutzungsbedingungen sowie Funk¬tionen zu Feedback und Bewertung der App sind über den Untermenupunkt „Info“ im Seitenmenu aufrufbar.  
# Betreiberin der App
Die Ingelheim zur Römerzeit App wird betrieben von der   
Stadtverwaltung Ingelheim   
Museum bei der Kaiserpfalz  
François-Lachenal-Platz 5   
55218 Ingelheim am Rhein  
Telefon: 06132/714701  
info-museum@ingelheim.de  
https://www.museum-ingelheim.de  

Das Museum bei der Kaiserpfalz wird vertreten durch die Museumsleiterin Dr. Ingeborg Domes.
 
# App Entwicklung
Extended Vision  
Kaiser-Joseph-Straße 254  
79098 Freiburg  
E-Mail: info@future-history.eu  
Website: https://www.future-history.eu  

# 3D-Rekonstruktion und Visualisierungen
Link3D  
Im Großacker 4b  
79249 Merzhausen  
E-Mail: info@link3d.eu  
Website: https://www.link3d.de  

# Lizenzierung
Copyright © 2023 Stadtverwaltung Ingelheim, Museum bei der Kaiserpfalz im Rahmen des Verbundprojekts museum4punkt0.  

Die Codeteile des Moduls "Aufruf 360 Grad Panorama" sind unter der GPLv3 Lizenz veröffentlicht.  

Future History ist eine eingetragene Marke der Extended Vision, Freiburg.  

Die im Repository enthaltenen Inhalte sind Creative Commons lizenziert CC-BY-SA 4.0 – Namensnennung, Weitergabe unter gleichen Bedingungen <https://creativecommons.org/licenses/by-sa/4.0/deed.de>