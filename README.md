# FLT-Projects
 Projects examining the feature listing task and reprocessed Buchanan et al. 2019

We are doing things!


## Data notes (`raw_data_all/all_data.csv`)

Built by `00_anonymize_create_ss.ipynb`. Columns: `subject_id` (globally unique), `file_subject_id` (ID within the source file), `source_file`, `word` (cue, lowercased), `answer`.

- `subject_id` is globally unique. In `mturk_file_1`–`9` it follows the hashed WorkerId, so a worker who appears in several MTurk files keeps one ID. `file_subject_id` is the ID within the source file (the hash for MTurk).
- `word_list_5_long.csv` IDs come from MTurk rows without worker IDs, so each row (one person) gets its own ID. The same person may appear in more than one row, but that can't be determined.
- Empty answers and exact duplicate (subject, word, answer) rows were removed.
- Original processing of the cue-level data is in the Word-Norms-2 repository.
