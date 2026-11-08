# FLT-Projects
 Projects examining the feature listing task and reprocessed Buchanan et al. 2019

We are doing things!


## Data notes (`raw_data_all/all_data.csv`)

Built by `00_anonymize_create_ss.ipynb`. Columns: `subject_id` (globally unique), `file_subject_id` (ID within the source file), `source_file`, `word` (cue, lowercased), `answer`, plus `wiki_flag`, `wiki_method` and `wiki_rule` (below).

- `subject_id` is globally unique. In `mturk_file_1`–`9` it follows the hashed WorkerId, so a worker who appears in several MTurk files keeps one ID. `file_subject_id` is the ID within the source file (the hash for MTurk).
- `word_list_5_long.csv` IDs come from MTurk rows without worker IDs, so each row (one person) gets its own ID. The same person may appear in more than one row, but that can't be determined.
- Empty answers and exact duplicate (subject, word, answer) rows were removed.
- Original processing of the cue-level data is in the Word-Norms-2 repository.
- Cue spellings were standardized to the 2019 word list (`don't` to `dont`, `celcius` to `celsius`, `condfidence` to `confidence`, `innoncent` to `innocent`, and "book bag" to `bookbag`).
- The cue `cider` (16 rows, `individual_subjects`) is excluded. It is not in the 2019 cue list or any 2019 file; the answers are about cinder blocks, so it appears to be a stray cue from the 2013 collection.
- `word_list_23b` (cues in `wl23b.csv`) comes from `transpose.txt` in the original `8 norming 1/data/subject files/word list 23` folder; it was not in the earlier source files. MTurk cue `None` was previously read as a missing value and is now kept.
- Some 2019 `0.5 raw words` files contain duplicated lines (re-running the append-mode Perl reader), so their line counts are higher than the number of participants here.
- `word_list_11` is a wide file (one column per cue) and is processed with the other wide files (10, 12, 13).

### Wikipedia / dictionary answers

Rows are never dropped for this; use the columns to exclude them in later steps.

- `wiki_flag`: TRUE = the answer was removed by the original Word-Norms-2 cleaning (`0.5 raw words` vs `1 spell checked` vs `1.5 raw words no wiki/_fixed`); FALSE = kept; blank = could not be determined.
- `wiki_method`: how `wiki_flag` was determined. `exact`/`fuzzy` (line-by-line comparison; `fuzzy` when line counts differ), `aligned` (spell-checked and `_fixed` files lost their line breaks, so raw words were aligned to the kept text), `*_text_similar` (the answer matched the 2019 raw line only approximately, since those files were lightly cleaned), and `answer_not_in_raw` / `cue_not_in_raw` (no decision available).
- `wiki_rule`: text patterns typical of pasted definitions (`numbered_senses`, `semicolon_definition`, `pos_tag`, `web_text`, `very_long` = over 500 characters, reviewed by hand). It is independent of `wiki_flag`.
- `review/long_answers_over_500.csv` lists the answers covered by `very_long`.
