Franchise Market Türkiye – Flutter MVVM Dokümantasyonu (Kurumsal Standart)

Bu doküman, franchisemarketturkiye.com mobil uygulamasında geliştirmenin tek referans kaynağıdır. “Unutursan bunu oku” dokümanı olarak tasarlanmıştır.
Hedef: Basit, kurumsal, tekrar etmeyen, API merkezli, MVVM + Services mimarisi.

1) Temel Kurallar (Tartışmasız)
🔴 API Response Zorunluluğu (KESİN KURAL)

API’dan gelen tüm response body’ler eksiksiz kullanılmak zorundadır.

Backend’in gönderdiği alanlar:

yok sayılmaz

“şimdilik lazım değil” denilerek atlanmaz

manuel/statik değerle override edilmez

🔴 API Authorization (ÖNEMLİ)

Tüm isteklerde aşağıdaki headerlar zorunludur:
- `Accept`: `application/json`
- `X-API-KEY`: `FMTRK_PROD_1234567890abcdef1234567890abcdef`

Bu key olmadan istekler 401 hatası alır.

Response içinde gelen:

data

meta

pagination

status

message

errors
gibi alanların tamamı modele karşılık gelmelidir.

Yasaklar

API response’un sadece bir kısmını map etmek ❌

UI’da “geçici” statik değer kullanmak ❌

Backend’in gönderdiği flag/alan varken frontend’de yeni flag üretmek ❌

Zorunluluklar

Her endpoint için birebir Model oluşturulur.

Model, response body’yi tam kapsar.

Kullanılmayan alanlar bile:

Model’de bulunur

Nullable olarak tanımlanır

ViewModel, sadece API’dan gelen veriyle state üretir.

2) Proje Klasör Yapısı (Zorunlu)

Önerilen minimal ve net yapı:

lib/
  app/
    app_constants.dart
    api_constants.dart
    app_theme.dart

  core/
    network/
      api_client.dart
      api_result.dart
      api_exception.dart
    utils/
      logger.dart
      validators.dart
    widgets/
      app_loader.dart
      app_error.dart
      app_empty.dart

  models/
    ...

  services/
    ...

  viewmodels/
    ...

  views/
    ...


“Basit mimari” şartı gereği feature-based klasörleme zorunlu değil; ama büyürse views/<feature> ve viewmodels/<feature> altına toplanabilir.

3) Sorumluluklar (Net Ayrım)
AppConstant (app_constants.dart)

Uygulama genel sabitleri: timeout, pagination default, locale, cache key’leri vb.

Endpoint içermez.

ApiConstant (api_constants.dart / apiconstants.dart)

Tüm endpointler burada: path’ler, baseUrl, versiyonlar.

Örnek yapı:

baseUrl

authLogin

franchiseList

franchiseDetail

categories

cities

filters

ViewModel/Service içinde “/v1/franchise” gibi string yazmak yasak.

AppTheme (app_theme.dart)

Renkler, text style’lar, spacing ölçüleri, component theme’leri.

View içinde inline stil yazmayı minimumda tut.

4) MVVM Akışı (Nasıl Çalışır?)

View → ViewModel → Service → ApiClient → HTTP → Service → ViewModel → View

View

UI render eder.

Sadece ViewModel state’ini dinler ve event gönderir.

ViewModel

Ekran mantığı, state yönetimi.

Service çağırır.

UI’ya uygun state üretir (loading / data / empty / error).

Service

API konuşması + response mapping.

ViewModel’e “ham HTTP” döndürmez; işlenmiş model döndürür.

Model

JSON parse / serialize.

UI logic barındırmaz.

5) Network Standardı (Tek Yerden Yönet)
ApiClient (core/network/api_client.dart)

Tüm HTTP istekleri buradan geçer:

baseUrl: ApiConstants.baseUrl

ortak header (token varsa)

timeout

hata yakalama

loglama

ApiResult (core/network/api_result.dart)

Servis dönüş standardı:

Success<T>(data)

Failure(error)

ViewModel, UI state’i buna göre kurar.

ApiException (core/network/api_exception.dart)

Tüm hata türleri burada normalize edilir:

network yok

timeout

401/403 auth

404

500

parse error

Amaç: ViewModel’de “statusCode == 500” gibi kontrol tekrarı olmaması.

6) Service Standardı (Kurumsal Şablon)

Her service sınıfı:

Tek domain: ör. FranchiseService, AuthService, LookupService

Dışarıya “HTTP Response” vermez.

Metot isimleri fiil + nesne:

getFranchiseList(...)

getFranchiseDetail(id)

login(...)

getCategories()

Service içinde:

Endpoint: sadece ApiConstants.xxx

Parse: Model.fromJson

7) Model Standardı

Her model:

fromJson(Map<String, dynamic> json)

toJson()

Nullable alanlar doğru işlenir.

Tarihler parse edilir (string bırakılmaz).

“UI’ya özel alan” modelde tutulmaz (örn: isSelected gerekiyorsa ViewModel state’inde tutulur).

8) ViewModel Standardı (Ekran Mantığı)

Her ViewModel:

state alanları:

bool isLoading

String? errorMessage

List<T> veya T? detail

pagination varsa: page, hasMore, isLoadingMore

lifecycle:

init() veya onReady()

refresh()

loadMore() (varsa)

UI event metotları:

onSearchChanged

onFilterChanged

onRetry

ViewModel, tek ekrana hizmet eder. “Her şeyi yapan mega ViewModel” yasak.

9) View Standardı (UI Kuralları)

View sadece:

state gösterir

event çağırır

Durum ekranları standart olmalı:

Loading → AppLoader

Error → AppError(onRetry)

Empty → AppEmpty

Liste/detay bileşenleri tekrar ediyorsa core/widgets altına alınır.

10) Tekrarı Sıfırlayan Prensipler

Tekrarlama tespit checklist’i:

Aynı loader UI 2+ yerde mi? → ortak widget

Aynı try-catch 2+ yerde mi? → ApiClient

Aynı json parse map’i 2+ yerde mi? → Model

Aynı endpoint string’i 2+ yerde mi? → ApiConstants

Aynı padding/textStyle 2+ yerde mi? → AppTheme tokens

11) Performans & Temizlik

Liste ekranlarında:

pagination + lazy load

gereksiz rebuild engelle (state’i minimal değiştir)

Ağ çağrılarında:

gereksiz aynı isteği tekrar atma

search debounce (gerekliyse)

UI’da:

ağır widgetları böl

sabit widgetlar const yapılır (statik veri değil, widget const)

12) Zorunlu İsimlendirme ve Dosyalama

Dosya isimleri: snake_case.dart

Sınıf isimleri: PascalCase

View:

franchise_list_view.dart

ViewModel:

franchise_list_view_model.dart

Service:

franchise_service.dart

Model:

franchise.dart, category.dart vb.

13) Uygulama İçin Minimum Başlangıç Modülleri (Öneri)

Auth: login / token / session

Franchise: liste + detay

Lookup: kategori, şehir, filtre seçenekleri (hepsi API)

Favorites (varsa): API ile

Profile (varsa)

14) “Unutma” Bölümü (En Kritik Hatırlatmalar)

Statik veri yok → her şey API’dan

Endpoint string yazma → sadece apiconstants.dart

Tekrarlama yok → ortak client/service/widget

View sade → logic ViewModel’de

Service ham response döndürmez → model döndürür

Hata yönetimi tek yerde → ApiClient + ApiException

Theme ve sabitler tek yerde → AppTheme + AppConstants

15) Tasarım Referansı (Zorunlu)

Mobil uygulamanın tasarımı her zaman franchisemarketturkiye.com web sitesini baz alacaktır.

Renk paleti, tipografi, spacing, görsel hiyerarşi ve komponent davranışları siteyle uyumlu olacaktır.

Keyfi UI/UX kararları alınmaz; sapma gerekiyorsa önce site referansı, sonra gerekçeli karar.

Mobilde birebir kopya değil, siteyi temel alan, mobil uyarlanmış (responsive & native) tasarım uygulanır.

Tüm tasarım kararları AppTheme üzerinden yönetilir; View içinde inline stil yazımı minimumda tutulur.