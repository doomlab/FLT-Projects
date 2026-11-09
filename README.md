# FLT-Projects

Feature listing task (FLT) data: the reprocessing of the Buchanan et al. 2019 word norms. The raw answers from every collection (subject files, MTurk, word lists) are combined, cleaned and turned into one word per row, plus a cue-by-feature count table.

**Start here**

| File | What it is |
|---|---|
| `processed/09_cue_feature_counts.csv` | Final summary: for every cue and word, how many people listed it. Nothing is filtered out. |
| `processed/08_words.csv` | One row per person, cue and word (with `position`). |
| `raw_data_all/all_data.csv` | Every answer in one file, with flags for answers to leave out. |
| [COMPARISON.md](COMPARISON.md) | How close the new cosines are to the original 2019 ones. |

## Processing steps

Run in order with the `flt-nlp` conda environment (`environment.yml`, then `python -m spacy download en_core_web_sm`). Each notebook reads the previous file and writes the next one into `processed/`. `row_id` (the row in `all_data.csv`) follows every answer through all steps.

| Notebook | Output | What it does |
|---|---|---|
| `00_anonymize_create_ss.ipynb` | `raw_data_all/all_data.csv` | Builds one long file from every source; adds the exclusion flags (below) |
| `01_filter_clean.ipynb` | `01_filtered.csv` | Removes flagged rows (kept in `01_removed.csv` with the reason), cleans and lowercases text |
| `02_expand_contractions.ipynb` | `02_contractions.csv` | "don't" to "do not" |
| `03_spell_check.ipynb` | `03_spelling.csv` | Spelling. Override anything in `dictionaries/spelling_hand_fixes.csv`; review `03_spelling_changes.csv` and `03_spelling_unresolved.csv` |
| `04_expand_abbreviations.ipynb` | `04_abbreviations.csv` | "dr" to "doctor", "rd" to "road", etc. |
| `05_lemmatize.ipynb` | `05_lemmatized.csv` | spaCy lemmas ("legs" to "leg") |
| `06_spell_out_numbers.ipynb` | `06_numbers.csv` | "4" to "four" |
| `07_stop_words.ipynb` | `07_stopwords.csv` | Tidies odd tokens, removes stop and filler words and the cue word. Cues that are themselves stop words (`on`, `above`, ...) keep theirs (`07_exempt_cues.csv`) |
| `08_split_words.ipynb` | `08_words.csv`, `08_cue_counts.csv` | One row per person, cue and word; a repeated word in an answer is kept once |
| `09_cue_feature_counts.ipynb` | `09_cue_feature_counts.csv` | Counts for every cue-word pair (`count`, `prop_final`, `prop_answered`, `mean_position`) |
| `10_compare_cosines.ipynb` | `10_cosine_*.csv/png` | Compares cue-cue cosines with the original 2019 root cosines |
| `11_split_half_ceiling.ipynb` | `11_split_half_ceiling.csv`, `11_split_half_summary.csv` | How well two random halves of the people agree for each cue (top-10 feature-mass coverage): the ceiling for any method scored against these norms |
| `12_merge_lemmas.ipynb` (uses `merge_lemmas.py`) | `12_cue_feature_counts_merged.csv`, `dictionaries/lemma_merge.csv` | Merges related words into one lemma (`gambling`/`gamble`, `luck`/`lucky`, `people`/`person`): the 2019 translation dictionary (`dictionaries/translation_2019.csv`) plus the 2019 affix rules for other words, checked against WordNet. Adds `lemma`, `frequency_lemma` and `normalized_lemma` next to the original `feature` columns. Words to keep separate: `dictionaries/lemma_keep_separate.csv` |

## Folders

| Folder | Contents |
|---|---|
| `raw_data/` | One cleaned long-format file per source (from notebook 00) |
| `raw_data_all/` | The combined `all_data.csv` |
| `processed/` | Output of each step, plus review files |
| `dictionaries/` | Inputs used by the notebooks: `contraction_dict.csv`, `spelling_dict_edited.xlsx` (only its checked entries are used), `spelling_hand_fixes.csv` (your overrides) |
| `review/` | `long_answers_over_500.csv`: the long answers excluded by the `very_long` rule |
| `raw_data_nosync/` | Original files with worker ids and the salt. **Not tracked by git.** |

## The combined data (`raw_data_all/all_data.csv`)

Columns: `subject_id` (unique across all data), `file_subject_id` (id within the source file), `source_file`, `word` (the cue, lowercased), `answer`, `assignment_status` (MTurk only: Approved or Rejected), `wiki_flag`, `wiki_method`, `wiki_rule`.

- In `mturk_file_1`–`9`, `subject_id` follows the hashed worker id, so a worker who appears in several files keeps one id.
- `word_list_5_long` came from MTurk rows without worker ids, so each row gets its own id. The same person may be in more than one row, but that can't be determined.
- Empty answers and exact duplicate (subject, cue, answer) rows were removed.
- Cue spellings follow the 2019 word list (`don't` to `dont`, `celcius` to `celsius`, `condfidence` to `confidence`, `innoncent` to `innocent`, "book bag" to `bookbag`). `word_list_11` is a wide file and is processed with the other wide files (10, 12, 13).
- `word_list_23b` comes from the original word list 23 files (`wl23b.csv` lists its cues, `transpose.txt` has the answers); it was missing from the earlier sources. MTurk cue `None` is kept as text.
- The cue `cider` (16 rows) is excluded: it is not in the 2019 cue list, and the answers are about cinder blocks.

### Answers to leave out

Rows are never dropped in `all_data.csv`. Leave out a row when `wiki_flag` is TRUE or `wiki_rule` is not blank; notebook 01 does this.

- `wiki_flag`: TRUE = the original Word-Norms-2 cleaning removed the answer (found by comparing its `0.5 raw words`, `1 spell checked` and `1.5 raw words no wiki/_fixed` folders). Answers with no original decision are FALSE.
- `wiki_method`: how `wiki_flag` was decided: `exact` or `fuzzy` (line comparison; `fuzzy` when line counts differ), `aligned` (the 2019 files lost their line breaks), `*_text_similar` (the answer only approximately matched the 2019 raw line), `answer_not_in_raw` / `cue_not_in_raw` (no decision available).
- `wiki_rule` lists the reasons an answer looks like pasted text or does not belong:
  - `numbered_senses`, `semicolon_definition`, `pos_tag`, `web_text`, `article_text`: dictionary or web-page patterns
  - `very_long`: over 500 characters (reviewed by hand)
  - `long_duplicate`: the same answer of over 40 characters already appeared earlier in the same cue (later copies only; short repeated answers are kept)
  - `rejected_hit`: the answer is from a rejected MTurk assignment
  - `stray_cue`: the cue is not in the 2019 cue list (for example a wrapped line read as a cue)

## Things to know

- `08_words.csv` has `n_answered` (people who answered the cue, before any exclusions) and `n_final` (people who still have a word for it); `08_cue_counts.csv` has both for every cue. Use `n_final`, not the 2019 N values, for shares. A few cues have very little usable data (`something`, `soda`, `cracker`, where workers pasted dictionary definitions).
- About 6,900 `individual_subjects` answers could not be matched to the 2019 files and are treated as kept.
- Some 2019 `0.5 raw words` files repeat long answers (for example `kiss` has whole blocks of lines twice), so their line counts are higher than the number of participants here. The cause is not confirmed.
- **Worker ids** are hashed with SHA-256 and a secret salt (`raw_data_nosync/salt.txt`, not tracked). Keep a private copy of the salt; it is only needed to regenerate the same ids from the raw MTurk files, not to use the data.
