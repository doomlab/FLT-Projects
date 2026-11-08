# FLT-Projects
 Projects examining the feature listing task and reprocessed Buchanan et al. 2019

We are doing things!


## Data notes (`raw_data_all/all_data.csv`)

Built by `00_anonymize_create_ss.ipynb`. Columns: `subject_id` (globally unique), `file_subject_id` (ID within the source file), `source_file`, `word` (cue, lowercased), `answer`, plus `assignment_status` (MTurk files only: Approved or Rejected), `wiki_flag`, `wiki_method` and `wiki_rule` (below).

- `subject_id` is globally unique. In `mturk_file_1`–`9` it follows the hashed WorkerId, so a worker who appears in several MTurk files keeps one ID. `file_subject_id` is the ID within the source file (the hash for MTurk).
- `word_list_5_long.csv` IDs come from MTurk rows without worker IDs, so each row (one person) gets its own ID. The same person may appear in more than one row, but that can't be determined.
- Empty answers and exact duplicate (subject, word, answer) rows were removed.
- Original processing of the cue-level data is in the Word-Norms-2 repository.
- Cue spellings were standardized to the 2019 word list (`don't` to `dont`, `celcius` to `celsius`, `condfidence` to `confidence`, `innoncent` to `innocent`, and "book bag" to `bookbag`).
- The cue `cider` (16 rows, `individual_subjects`) is excluded. It is not in the 2019 cue list or any 2019 file; the answers are about cinder blocks, so it appears to be a stray cue from the 2013 collection.
- `word_list_23b` (cues in `wl23b.csv`) comes from `transpose.txt` in the original `8 norming 1/data/subject files/word list 23` folder; it was not in the earlier source files. MTurk cue `None` was previously read as a missing value and is now kept.
- Some 2019 `0.5 raw words` files repeat long answers (e.g., `kiss` has whole blocks of lines twice), so their line counts are higher than the number of participants here. Cause not confirmed.
- `word_list_11` is a wide file (one column per cue) and is processed with the other wide files (10, 12, 13).

### Wikipedia / dictionary answers

Rows are never dropped for this; use the columns to exclude them in later steps.

- `wiki_flag`: TRUE = the answer was removed by the original Word-Norms-2 cleaning (`0.5 raw words` vs `1 spell checked` vs `1.5 raw words no wiki/_fixed`); FALSE = kept. Answers with no original decision available (`wiki_method` = `answer_not_in_raw` or `cue_not_in_raw`) are set to FALSE, so there are no blanks.
- `wiki_method`: how `wiki_flag` was determined. `exact`/`fuzzy` (line-by-line comparison; `fuzzy` when line counts differ), `aligned` (spell-checked and `_fixed` files lost their line breaks, so raw words were aligned to the kept text), `*_text_similar` (the answer matched the 2019 raw line only approximately, since those files were lightly cleaned), and `answer_not_in_raw` / `cue_not_in_raw` (no decision available).
- `wiki_rule`: text patterns typical of pasted definitions (`numbered_senses`, `semicolon_definition`, `pos_tag`, `web_text`, `very_long` = over 500 characters, reviewed by hand, `long_duplicate` = the same answer of over 40 characters already appeared earlier in the same cue (later copies only; short repeated answers are kept), and `rejected_hit` = the answer is from an MTurk assignment that was rejected (`assignment_status` = Rejected), and `stray_cue` = the cue is not in the 2019 cue list, e.g. a wrapped line read as a cue; remove these). It is independent of `wiki_flag`.
- `review/long_answers_over_500.csv` lists the answers covered by `very_long`.

## Processing steps

Run in order with the `flt-nlp` environment (`environment.yml`; then `python -m spacy download en_core_web_sm`). Each notebook reads the previous file in `processed/` and writes the next one.

| Notebook | Output | What it does |
|---|---|---|
| `00_anonymize_create_ss.ipynb` | `raw_data_all/all_data.csv` | Builds one long file from every source; adds `wiki_flag`, `wiki_method`, `wiki_rule` |
| `01_filter_clean.ipynb` | `01_filtered.csv` | Removes flagged rows (`01_removed.csv`), cleans and lowercases text |
| `02_expand_contractions.ipynb` | `02_contractions.csv` | "don't" to "do not" |
| `03_spell_check.ipynb` | `03_spelling.csv` | Spelling; edit `output_data/spelling_hand_fixes.csv` to override; review `03_spelling_changes.csv` and `03_spelling_unresolved.csv` |
| `04_expand_abbreviations.ipynb` | `04_abbreviations.csv` | "dr" to "doctor", "rd" to "road", etc. |
| `05_lemmatize.ipynb` | `05_lemmatized.csv` | spaCy lemmas ("legs" to "leg") |
| `06_spell_out_numbers.ipynb` | `06_numbers.csv` | "4" to "four" |
| `07_stop_words.ipynb` | `07_stopwords.csv` | Tidies odd tokens, removes stop and filler words and the cue word. Cues that are themselves stop words (`on`, `above`, ...) keep theirs (`07_exempt_cues.csv`) |
| `08_split_words.ipynb` | `08_words.csv` | One row per person, cue and word, with `position`; repeated words in an answer kept once |

`row_id` (the row in `all_data.csv`) follows every answer through all steps.


`08_words.csv` also has `n_answered` (people who answered the cue, before any exclusions) and `n_final` (people who still have a word for it); `08_cue_counts.csv` has both for every cue. Use `n_final`, not the 2019 N values, for shares. Cues with a small `n_final` (for example `something`, `soda`, `cracker`, where workers pasted dictionary definitions) have very little usable data.

**Worker IDs:** MTurk worker ids are hashed with SHA-256 and a secret salt (`raw_data_nosync/salt.txt`, not tracked). Keep a private copy of the salt; it is only needed to regenerate the same ids from the raw MTurk files, not to use the data.
