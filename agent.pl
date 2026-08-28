dynamic patient_symptom/1.
:- dynamic diagnosed/1.

symptom(yellow_leaves).
symptom(brown_spots).
symptom(wilting).
symptom(white_powder).
symptom(stunted_growth).
symptom(leaf_curling).

disease_symptoms(leaf_blight, [brown_spots, wilting]).
disease_symptoms(powdery_mildew, [white_powder, yellow_leaves]).
disease_symptoms(root_rot, [wilting, yellow_leaves, stunted_growth]).
disease_symptoms(mosaic_virus, [leaf_curling, stunted_growth, yellow_leaves]).

remedy(
    leaf_blight,
    'Apply copper-based fungicide and remove infected leaves.'
).

remedy(
    powdery_mildew,
    'Apply sulfur spray and improve air circulation.'
).

remedy(
    root_rot,
    'Improve soil drainage and reduce watering frequency.'
).

remedy(
    mosaic_virus,
    'Remove infected plants and control aphid population.'
).

patient_symptom(brown_spots).
patient_symptom(wilting).

match_count(Disease, Count) :-
    disease_symptoms(Disease, Symptoms),
    findall(
        S,
        (member(S, Symptoms), patient_symptom(S)),
        Matched
    ),
    length(Matched, Count).

candidate(Disease, Count) :-
    disease_symptoms(Disease, _),
    match_count(Disease, Count),
    Count > 0.

diagnose(BestDisease) :-
    findall(
        Count-Disease,
        candidate(Disease, Count),
        Pairs
    ),
    Pairs \= [],
    keysort(Pairs, Sorted),
    last(Sorted, _-BestDisease).

perform(diagnose) :-
    diagnose(Disease),
    !,
    remedy(Disease, Remedy),
    format("Diagnosis: Plant likely has ~w.~n", [Disease]),
    format("Recommended remedy: ~w~n", [Remedy]),
    assert(diagnosed(Disease)).

perform(no_match) :-
    format(
        "No matching disease found for given symptoms. Consult an expert.~n",
        []
    ).

start :-
    (diagnose(_) ->
        perform(diagnose)
    ;
        perform(no_match)
    ).

show_symptoms :-
    findall(S, patient_symptom(S), List),
    format("Current recorded symptoms: ~w~n", [List]).

add_symptom(S) :-
    (patient_symptom(S) ->
        true
    ;
        assert(patient_symptom(S))
    ),
    format("Symptom '~w' recorded.~n", [S]).

reset :-
    retractall(patient_symptom(_)),
    retractall(diagnosed(_)),
    assert(patient_symptom(brown_spots)),
    assert(patient_symptom(wilting)),
    format("Simulation reset. Default symptoms loaded.~n", []).
