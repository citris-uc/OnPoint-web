# README
## Introduction
This app is primarily used in cases where direct access to Firebase does not make sense.

To get the app up and running, you will need a `config/application.yml` file.
Because it contains sensitive information, this file is not in the git history.
Ask Dmitri to share with you.

Once you've added the file, run `bundle install && bundle exec foreman start`.

The production web app is available at onpointhealth.herokuapp.com, lives on Heroku and is served by the `master` branch of `OnPoint-web` repo. It is managed
by Dmitri (dmitriskj@gmail.com).

Please refer to README.md of `OnPoint` repo for any other information.

## Understanding how Firebase works with Rails
They don't have native admin support for Auth in Rails (Java or Node.js), but you can access the database using legacy keys. See [Firebase PHP](https://github.com/ktamas77/firebase-php/issues/42) on why, and here is a [guide on setting up Admin SDK](https://firebase.google.com/docs/admin/setup)


## Verifying identity on Rails
Firebase doesn't support native id verification, so we have to write our own
JWT parser. Source: https://firebase.google.com/docs/auth/admin/verify-id-tokens

Here is a detailed setup on getting ID verification working with JWT + Rails:
https://groups.google.com/forum/#!topic/firebase-talk/iefJWQ9LMQE


## RxNorm
Rx API is actually an API system of multiple systems:

RxNorm - Main API for fetching various information about a drug
RxTerms -
DailyMed (https://dailymed.nlm.nih.gov/dailymed/index.cfm) - exposes information on the drugs (purpose, risks, etc)

RxNorm API allows the user to search by approximate term using this endpoint:

```
https://rxnav.nlm.nih.gov/RxNormAPIs.html#uLink=RxNorm_REST_getApproximateMatch
```

The response is an array of matches, ordered by "score", with a corresponding rxcui, which is RxNorm's Unique Identifier in the system. We can get all properties of a drug using that rxcui like so:

```
https://rxnav.nlm.nih.gov/REST/rxcui/856999/allProperties.json?prop=all
```

One of these properties is "RxNorm Name", which I think is what people mean when they say "I use XYZ drug" (e.g. Metformin, Zestril, Lortab). Some drugs have alternative names.

The RxNorm API actually does NOT have image information. A separate API, RxImage, contains that information, and we can again use rxcui to access pill images:

```
https://rximage.nlm.nih.gov/api/rximage/1/rxnav?rxcui=856999
```

#### Remaining questions
1. What is the mapping between Medication barcode and RxNorm? This may help: https://rxnav.nlm.nih.gov/RxNormAPIs.html#uLink=RxNorm_REST_findRxcuiById
2. There are immense permutations for arbitrary search terms like hydrocodone. This is primarily because of the combinations you can get with Branded drugs, and branded dose groups. All possible Term Types are listed here: https://www.nlm.nih.gov/research/umls/rxnorm/docs/2015/appendix5.html. What should
we expect the patient to be exposed to? Most likely SBD? To get an idea, simply visit https://mor.nlm.nih.gov/RxNav/search?searchBy=String&searchTerm=HYDROcodone and look at the right-hand side.
3. Is it possible the dosage will go outside of a pre-defined branded drug dose? E.g. doctors manipulates the mg dosage (probably not).
4. How can we leverage and use DailyMed?


## OCR
We use the `ocr_space` gem to extract pill bottle information. The gem uses Microsoft technology available in the [OCR.space API](https://ocr.space/).
