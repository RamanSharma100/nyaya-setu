import '../../shared/models/bare_act.dart';

List<BareAct> getMinorBareActs() {
  return [
    BareAct(
      id: 'ica',
      title: 'Indian Contract Act, 1872',
      shortTitle: 'Contract (ICA)',
      enactmentYear: 1872,
      category: 'Contract Law (Minor Act)',
      isMinor: true,
      totalSections: 238,
      description:
          'Governs contract formation, free consent, consideration, void agreements, performance, frustration, and damages.',
      sections: [
        Section(
          sectionNumber: '2(h)',
          chapter: 'Preliminary',
          title: 'Definition of Contract',
          content:
              'An agreement enforceable by law is a contract.\n\nClause (e): Every promise and every set of promises, forming the consideration for each other, is an agreement.\n\nClause (g): An agreement not enforceable by law is said to be void.',
          explanation:
              'Contract = Agreement + Legal Enforceability. All contracts are agreements, but all agreements are not contracts.',
          punishment: 'Civil Remedy / Enforceability',
          bailable: true,
          cognizable: false,
          triableBy: 'Civil Courts',
          examples: [
            'Practical Example 1: A invites B to a social dinner party. B accepts. A cancels at the last moment. B cannot sue A because social invitations lack intention to create legal relations (Balfour v Balfour).',
            'Practical Example 2: Merchant X agrees to sell 100 bags of wheat to Y for ₹2,00,000. This is a commercial agreement intending legal relations, creating a binding contract under Section 2(h).',
          ],
          keyIngredients: [
            'Plurality of persons (at least 2 parties).',
            'Consensus ad idem (Meeting of minds on the same thing in the same sense).',
            'Intention to create legal obligations.',
            'Lawful consideration and object.',
          ],
          landmarkCases: [
            'Balfour v. Balfour (1919) 2 KB 571 - Domestic/social arrangements lack intention to create legal relations.',
            'Carlill v. Carbolic Smoke Ball Co. (1893) 1 QB 256 - General offer accepted by performance of condition.',
          ],
          examTips:
              'Classic Mains Question: "All contracts are agreements, but all agreements are not contracts." Discuss with reference to Sec 2(h) and Sec 10.',
        ),
        Section(
          sectionNumber: '10',
          chapter: 'Chapter II - Of Contracts, Voidable Contracts and Void Agreements',
          title: 'What agreements are contracts',
          content:
              'All agreements are contracts if they are made by the free consent of parties competent to contract, for a lawful consideration and with a lawful object, and are not hereby expressly declared to be void.\n\nNothing herein contained shall affect any law in force in India, by which any contract is required to be made in writing or in the presence of witnesses, or any law relating to the registration of documents.',
          explanation:
              'Sets out the 4 indispensable pillars of a valid contract: Free consent (Sec 14), Competency (Sec 11), Lawful consideration/object (Sec 23), and Not declared void (Sec 24-30).',
          punishment: 'Civil Validity Requirement',
          bailable: true,
          cognizable: false,
          triableBy: 'Civil Courts',
          examples: [
            'Practical Example 1: A, by threatening to shoot B, compels B to sign an agreement to sell his bungalow worth ₹1 Crore for ₹10 Lakhs. Consent is obtained through Coercion (Sec 15). The contract is voidable at B\'s option under Sec 19.',
          ],
          keyIngredients: [
            'Free consent (Free from Coercion, Undue Influence, Fraud, Misrepresentation, Mistake).',
            'Competency of parties (Age of majority, Sound mind, Not disqualified by law).',
            'Lawful consideration and lawful object.',
            'Agreement not expressly declared void (e.g. Restraint of trade Sec 27, Wagering Sec 30).',
          ],
          landmarkCases: [
            'Mohori Bibee v. Dharmodas Ghose (1903) 30 IA 114 - Minor\'s agreement is void ab initio.',
            'Subhas Chandra Das Mushib v. Ganga Prosad Das Mushib (1967) 1 SCR 331 - Undue influence requirements.',
          ],
          examTips:
              'Essential for PCS-J Prelims: Memorize all grounds that vitiate free consent under Sections 14, 15, 16, 17, 18, 20, 21, and 22.',
        ),
        Section(
          sectionNumber: '56',
          chapter: 'Chapter IV - Of the Performance of Contracts',
          title: 'Agreement to do impossible act (Doctrine of Frustration)',
          content:
              'An agreement to do an act impossible in itself is void.\n\nContract to do act afterwards becoming impossible or unlawful: A contract to do an act which, after the contract is made, becomes impossible, or, by reason of some event which the promisor could not prevent, unlawful, becomes void when the act becomes impossible or unlawful.\n\nCompensation for loss through non-performance of act known to be impossible or unlawful: Where one person has promised to do something which he knew, or, with reasonable diligence, might have known, and which the promisee did not know, to be impossible or unlawful, such promisor must make compensation to such promisee for any loss.',
          explanation:
              'Codifies the Doctrine of Frustration (Subsequent or Supervening Impossibility). The contract automatically dissolves without breach when an untoward event destroys the foundation of the contract.',
          punishment: 'Contract Discharged / Restitution under Sec 65',
          bailable: true,
          cognizable: false,
          triableBy: 'Civil Courts',
          examples: [
            'Practical Example 1 (Destruction of Subject Matter): A agrees to let out his music hall to B for a grand concert on May 1st. On April 25th, the music hall is completely destroyed by an accidental fire without fault of either party. The contract is frustrated and both parties are discharged (Taylor v Caldwell).',
            'Practical Example 2 (Commercial Difficulty != Frustration): Merchant X contracts to supply imported steel at ₹50,000/ton. Due to foreign market fluctuations, steel price surges to ₹1,20,000/ton. X cannot claim frustration because commercial hardship or drop in profit does not frustrate a contract.',
          ],
          keyIngredients: [
            'Valid, subsisting contract between the parties.',
            'Performance becomes physically or legally impossible after contract formation.',
            'Impossibility caused by an external event beyond control and contemplation of parties.',
            'No fault, neglect, or self-induced impossibility by either party.',
          ],
          landmarkCases: [
            'Satyabrata Ghose v. Mugneeram Bangur & Co. (1954) SCR 310 - Constitutional bench ruling: Doctrine of frustration in India is completely codified within Sec 56 and does not depend on English common law implied terms.',
            'Energy Watchdog v. CERC (2017) 14 SCC 80 - Commercial difficulty or unforeseen expense does not amount to frustration.',
          ],
          examTips:
              'High Frequency Mains Question: Differentiate between Force Majeure (Sec 32 Contingent Contract) and Doctrine of Frustration (Sec 56). Always cite Satyabrata Ghose and Energy Watchdog.',
        ),
        Section(
          sectionNumber: '73',
          chapter: 'Chapter VI - Of the Consequences of the Breach of Contract',
          title: 'Compensation for loss or damage caused by breach of contract',
          content:
              'When a contract has been broken, the party who suffers by such breach is entitled to receive, from the party who has broken the contract, compensation for any loss or damage caused to him thereby, which naturally arose in the usual course of things from such breach, or which the parties knew, when they made the contract, to be likely to result from the breach of it.\n\nSuch compensation is not to be given for any remote and indirect loss or damage sustained by reason of the breach.\n\nExplanation: In estimating the loss or damage arising from a breach of contract, the means which existed of remedying the inconvenience caused by the non-performance of the contract must be taken into account (Duty to mitigate).',
          explanation:
              'Codifies the two limbs of the landmark English rule in Hadley v. Baxendale: (1) Ordinary Damages (natural consequences), (2) Special Damages (within contemplation at time of contract). Mandates mitigation of damages.',
          punishment: 'Judicial Award of Monetary Damages',
          bailable: true,
          cognizable: false,
          triableBy: 'Civil Courts',
          examples: [
            'Practical Example 1: Miller M sends a broken crankshaft to B, a carrier, to take to manufacturer. B delays delivery unreasonably. M\'s mill stops operating for 10 days, causing massive loss of commercial profits. Because M did not inform B that the mill was idle solely for want of this shaft, B is only liable for ordinary delay damages, NOT the special loss of mill profits (Hadley v Baxendale).',
          ],
          keyIngredients: [
            'Breach of valid contract by defendant.',
            'Direct injury or financial loss sustained by plaintiff.',
            'Damages must be proximate (not remote or indirect).',
            'Plaintiff has an affirmative duty to take reasonable steps to mitigate damages.',
          ],
          landmarkCases: [
            'Hadley v. Baxendale (1854) 9 Exch 341 - Landmark foundational ruling laying down rules for ordinary and special damages.',
            'Kailash Nath Associates v. DDA (2015) 4 SCC 136 - Principles governing liquidated damages under Sec 74 and actual loss proof under Sec 73.',
          ],
          examTips:
              'Mains Problem Question Favorite: Examine whether loss of speculative profits can be recovered under Sec 73 without prior notice of special circumstances.',
        ),
      ],
    ),
    BareAct(
      id: 'sra',
      title: 'Specific Relief Act, 1963',
      shortTitle: 'Specific Relief (SRA)',
      enactmentYear: 1963,
      category: 'Civil Law (Minor Act)',
      isMinor: true,
      totalSections: 44,
      description:
          'Provides equitable remedies: recovery of possession, mandatory specific performance (2018 Reform), substituted performance, rectification, rescission, declaratory decrees, and injunctions.',
      sections: [
        Section(
          sectionNumber: '6',
          chapter: 'Part II - Specific Relief, Chapter I',
          title: 'Suit by person dispossessed of immovable property',
          content:
              'If any person is dispossessed without his consent of immovable property otherwise than in due course of law, he or any person through whom he has been in possession or any person claiming through him may, by suit, recover possession thereof, notwithstanding any other title that may be set up in such suit.\n\nNo suit under this section shall be brought: (a) after the expiry of six months from the date of dispossession; or (b) against the Government.\n\nNo appeal shall lie from any order or decree passed in any suit instituted under this section, nor shall any review of any such order or decree be allowed.',
          explanation:
              'Summary proceeding based purely on prior peaceful possession. Title is completely irrelevant. The object is to prevent people from taking the law into their own hands.',
          punishment: 'Restoration of Possession Decree',
          bailable: true,
          cognizable: false,
          triableBy: 'Civil Court',
          examples: [
            'Practical Example 1: Tenant T is forcefully locked out of his rented godown by Landlord L without court eviction order. T files a suit under Sec 6 within 4 months. Even though L is the true lawful owner, the Court immediately restores possession to T because L did not follow due process of law.',
          ],
          keyIngredients: [
            'Plaintiff had juridical and actual possession.',
            'Dispossessed without consent otherwise than in due course of law.',
            'Suit filed strictly within 6 months from the date of dispossession.',
            'Suit is not against Central or State Government.',
            'No appeal or review lies against Sec 6 decree (only Revision under Sec 115 CPC).',
          ],
          landmarkCases: [
            'Nair Service Society Ltd. v. K.C. Alexander (1968) 3 SCR 163 - Prior peaceful possession is good against all the world except the true owner.',
            'Lallu Yeshwant Singh v. Rao Jagdish Singh (1968) 2 SCR 203 - True owner cannot forcibly dispossess trespasser/tenant except by due legal process.',
          ],
          examTips:
              'High frequency Prelims Trap: Remember (1) Limitation is strictly 6 months, (2) No suit against Government, (3) No Appeal or Review allowed (only High Court Revision under Sec 115 CPC).',
        ),
        Section(
          sectionNumber: '10',
          chapter: 'Chapter II - Specific Performance of Contracts',
          title: 'Specific performance in respect of contracts (2018 Mandatory Regime)',
          content:
              'The specific performance of a contract shall be enforced by the court subject to the provisions contained in sub-section (2) of section 11, section 14 and section 16.\n\n(Amended by the Specific Relief Amendment Act, 2018, which substituted "shall be enforced" in place of the earlier discretionary "may, in the discretion of the court, be enforced".)',
          explanation:
              'Historic 2018 Amendment: Specific performance is no longer an equitable, discretionary remedy in India! It is now a MANDATORY statutory right of the plaintiff, subject only to Sec 11(2), 14, and 16.',
          punishment: 'Decree for Specific Performance',
          bailable: true,
          cognizable: false,
          triableBy: 'Civil Court',
          examples: [
            'Practical Example 1: V agrees to sell unique ancestral land to P. V later refuses, offering monetary compensation. Under amended Sec 10, the Court MUST grant specific performance and compel V to execute the sale deed, unless barred under Sec 14 or 16.',
          ],
          keyIngredients: [
            'Enforceable contract between plaintiff and defendant.',
            'Mandatory enforcement by court ("shall be enforced").',
            'Subject only to statutory bars under Section 11(2), Section 14 (non-enforceable contracts), and Section 16 (readiness and willingness).',
          ],
          landmarkCases: [
            'B. Santoshamma v. D. Sarala (2020) 19 SCC 80 - Supreme Court highlighted the paradigm shift from discretion to mandatory relief post-2018 amendment.',
            'Sughar Singh v. Hari Singh (2021) SCC OnLine SC 975 - Affirming mandatory nature of Sec 10.',
          ],
          examTips:
              'Must-know for Mains: Explain the significance of the 2018 Amendment replacing "may" with "shall" in Section 10 SRA. Emphasize how substituted performance under Sec 20 complements this shift.',
        ),
        Section(
          sectionNumber: '16',
          chapter: 'Chapter II - Specific Performance of Contracts',
          title: 'Personal bars to relief (Readiness and Willingness)',
          content:
              'Specific performance of a contract cannot be enforced in favour of a person: (a) who has obtained substituted performance under section 20; or (b) who has become incapable of performing, or violates any essential term; or (c) who fails to prove that he has performed or has always been ready and willing to perform the essential terms of the contract.',
          explanation:
              'Plaintiff must continuously plead and prove "readiness" (financial capacity) and "willingness" (mental inclination) from the date of contract until the date of decree.',
          punishment: 'Dismissal of Specific Performance Suit',
          bailable: true,
          cognizable: false,
          triableBy: 'Civil Court',
          examples: [
            'Practical Example 1: Buyer B sues Seller S for specific performance of land sale for ₹50 Lakhs. During trial, S shows that B did not have bank funds, loan sanction, or cash throughout the agreed period. B fails to prove readiness; suit is dismissed under Sec 16(c).',
          ],
          keyIngredients: [
            'Readiness refers to capacity (financial ability to pay consideration).',
            'Willingness refers to conduct and intent to execute contract.',
            'Must be continuous from agreement date to decree.',
            'Post-2018: Substituted performance under Sec 20 completely bars specific performance.',
          ],
          landmarkCases: [
            'Syed Dastagir v. T.R. Gopalakrishna Setty (1999) 6 SCC 337 - Readiness and willingness is not a mere formal phrase, it must be proved by evidence and conduct.',
            'U.N. Krishnamurthy v. A.M. Krishnamurthy (2022) SCC OnLine SC 840 - Reaffirming absolute mandate of continuous readiness.',
          ],
          examTips:
              'DJS & UP PCS-J Mains Question: Distinguish between "Readiness" and "Willingness" with leading Supreme Court precedents.',
        ),
        Section(
          sectionNumber: '34',
          chapter: 'Chapter VI - Of Declaratory Decrees',
          title: 'Discretion of court as to declaration of status or right',
          content:
              'Any person entitled to any legal character, or to any right as to any property, may institute a suit against any person denying, or interested to deny, his title to such character or right, and the court may in its discretion make therein a declaration that he is so entitled, and the plaintiff need not in such suit ask for any further relief:\n\nProvided that no court shall make any such declaration where the plaintiff, being able to seek further relief than a mere declaration of title, omits to do so.',
          explanation:
              'Allows removal of clouds over title or legal character. Proviso bars "bare declaration" if plaintiff is out of possession and omits to claim consequential possession relief.',
          punishment: 'Declaratory Decree',
          bailable: true,
          cognizable: false,
          triableBy: 'Civil Court',
          examples: [
            'Practical Example 1 (Proviso Bar): P is dispossessed of land by D. P files a suit seeking ONLY a declaration that P is owner, without asking for possession. The Court dismisses the suit under the Proviso to Sec 34 because P omitted the consequential relief of recovery of possession.',
          ],
          keyIngredients: [
            'Plaintiff must possess a legal character or right to property.',
            'Defendant is denying or interested to deny such right/character.',
            'Plaintiff must seek all consequential reliefs available (Proviso compliance).',
          ],
          landmarkCases: [
            'Ram Saran v. Ganga Devi (1973) 2 SCC 60 - Suit for mere declaration without asking for possession when plaintiff is out of possession is barred by Sec 34 Proviso.',
            'Union of India v. Ibrahim Uddin (2012) 8 SCC 148.',
          ],
          examTips:
              'Crucial Concept: What is the effect of the Proviso to Section 34? Why does law discourage multiple, piecemeal litigations?',
        ),
      ],
    ),
    BareAct(
      id: 'limitation',
      title: 'Limitation Act, 1963',
      shortTitle: 'Limitation Act',
      enactmentYear: 1963,
      category: 'Procedure (Minor Act)',
      isMinor: true,
      totalSections: 32,
      description:
          'Sets statutory time bars for suits, appeals, and applications. Codifies condonation of delay for sufficient cause (Sec 5), legal disability (Sec 6), acknowledgment (Sec 18), and adverse possession (Sec 27).',
      sections: [
        Section(
          sectionNumber: '3',
          chapter: 'Part II - Limitation of Suits, Appeals and Applications',
          title: 'Bar of limitation',
          content:
              'Subject to the provisions contained in sections 4 to 24 (inclusive), every suit instituted, appeal preferred, and application made after the prescribed period shall be dismissed, although limitation has not been set up as a defence.',
          explanation:
              'Section 3 casts a mandatory duty on the Court to dismiss a time-barred suit or appeal suo motu, even if the defendant has not pleaded limitation in the written statement. Limitation cannot be waived by consent.',
          punishment: 'Mandatory Dismissal of Action',
          bailable: true,
          cognizable: false,
          triableBy: 'All Courts',
          examples: [
            'Practical Example 1: Plaintiff files money recovery suit 3 years and 2 months after cause of action. Defendant admits debt and does not raise limitation defence. The Civil Court MUST dismiss the suit under Section 3 because parties cannot confer jurisdiction by waiver or consent.',
          ],
          keyIngredients: [
            'Applies to suits, appeals, and applications.',
            'Mandatory statutory command ("shall be dismissed").',
            'Independent duty of the court (no waiver or agreement can bypass limitation).',
            'Subject strictly to Sections 4 to 24 exceptions.',
          ],
          landmarkCases: [
            'Manindra Land and Building Corpn. v. Bhutnath Banerjee (1964) 3 SCR 495 - Section 3 mandate cannot be avoided even if limitation was not pleaded.',
            'Noharlal Verma v. District Coop. Central Bank Ltd. (2008) 14 SCC 445.',
          ],
          examTips:
              'Prelims Gold: Can parties agree in a contract to extend or waive the statutory limitation period? No, void under Section 28 Indian Contract Act and Section 3 Limitation Act.',
        ),
        Section(
          sectionNumber: '5',
          chapter: 'Part II - Limitation of Suits, Appeals and Applications',
          title: 'Extension of prescribed period in certain cases (Condonation of Delay)',
          content:
              'Any appeal or any application, other than an application under any of the provisions of Order XXI of the Code of Civil Procedure, 1908, may be admitted after the prescribed period, if the appellant or the applicant satisfies the court that he had sufficient cause for not preferring the appeal or making the application within such period.\n\nExplanation: The fact that the appellant or applicant was misled by any order, practice or judgment of the High Court in ascertaining or computing the prescribed period may be sufficient cause.',
          explanation:
              'Allows Court to condone delay for "Sufficient Cause". CRITICAL DISTINCTION: Section 5 applies ONLY to Appeals and Applications. It NEVER applies to original Suits or Execution Petitions under Order XXI CPC!',
          punishment: 'Condonation of Delay / Admission of Appeal',
          bailable: true,
          cognizable: false,
          triableBy: 'Appellate Courts & Tribunals',
          examples: [
            'Practical Example 1 (Legitimate Condonation): Appellant suffers severe stroke on last day of 30-day appeal limitation and remains hospitalized in ICU for 15 days. He files appeal on 46th day with medical hospital records. Court condones 15-day delay under Section 5 for sufficient cause.',
            'Practical Example 2 (Original Suit Inapplicable): P files an original partition suit 1 month after limitation expires. P requests Section 5 condonation. The Court must reject it because Section 5 expressly does NOT apply to original suits.',
          ],
          keyIngredients: [
            'Applies ONLY to Appeals and Applications.',
            'Expressly excludes original Suits and Order XXI CPC Execution Petitions.',
            'Applicant must prove "Sufficient Cause" for each day of delay after limitation expired.',
            'Discretionary equitable relief grounded in justice.',
          ],
          landmarkCases: [
            'Collector, Land Acquisition, Anantnag v. Mst. Katiji (1987) 2 SCC 107 - Supreme Court held that courts should adopt a liberal, justice-oriented approach rather than pedantic technicality.',
            'Ramlal v. Rewa Coalfields Ltd. (1962) 2 SCR 762 - Cause must explain delay after the expiration of prescribed period.',
          ],
          examTips:
              'Most Frequent PCS-J Trap: Does Section 5 apply to a Plaint in a Civil Suit? NEVER! It applies exclusively to Appeals and Applications.',
        ),
        Section(
          sectionNumber: '6',
          chapter: 'Part II - Limitation of Suits, Appeals and Applications',
          title: 'Legal disability (Minority, Insanity, Idiocy)',
          content:
              'Where a person entitled to institute a suit or make an application for the execution of a decree is, at the time from which the prescribed period is to be reckoned, a minor or insane, or an idiot, he may institute the suit or make the application within the same period after the disability has ceased, as would otherwise have been allowed from the time specified therefor in the third column of the Schedule.',
          explanation:
              'Protects persons under 3 recognized disabilities: Minor, Insane, Idiot. Prescribed limitation clock is paused until disability ceases. Section 8 provides a statutory ceiling of maximum 3 years after disability ceases.',
          punishment: 'Limitation Extension for Protected Persons',
          bailable: true,
          cognizable: false,
          triableBy: 'Civil Courts',
          examples: [
            'Practical Example 1: Minor M is 12 years old when his ancestral land is encroached upon (limitation 12 years). M turns 18 (attains majority). Under Section 6 read with Section 8, M has 3 years from attaining majority to file the recovery suit.',
          ],
          keyIngredients: [
            'Recognizes ONLY 3 legal disabilities: Minority, Insanity, Idiocy (Illness or poverty NOT recognized).',
            'Disability must exist AT THE TIME cause of action accrued.',
            'Subject to Section 8 ceiling: Maximum 3 years extension from cessation of disability.',
          ],
          landmarkCases: [
            'Darshan Singh v. Gurdev Singh (1994) 6 SCC 585 - Section 6 does not create a fresh period of limitation but only extends the time for filing.',
            'Bailochan Karan v. Basant Kumari Naik (1999) 2 SCC 310.',
          ],
          examTips:
              'Mains Problem: What happens if disability occurs after limitation has already started running? Section 9 applies: "Where once time has begun to run, no subsequent disability or inability to sue stops it."',
        ),
      ],
    ),
    BareAct(
      id: 'nia',
      title: 'Negotiable Instruments Act, 1881',
      shortTitle: 'NI Act (Sec 138)',
      enactmentYear: 1881,
      category: 'Commercial Law (Minor Act)',
      isMinor: true,
      totalSections: 148,
      description:
          'Regulates Promissory Notes, Bills of Exchange, and Cheques. Contains Chapter XVII for criminal prosecution of Cheque Dishonour under Section 138 and statutory presumptions.',
      sections: [
        Section(
          sectionNumber: '138',
          chapter: 'Chapter XVII - Of Penalties in case of Dishonour of Certain Cheques',
          title: 'Dishonour of cheque for insufficiency of funds in the account',
          content:
              'Where any cheque drawn by a person on an account maintained by him with a banker for payment of any amount of money to another person from out of that account for the discharge, in whole or in part, of any debt or other liability, is returned by the bank unpaid, either because of the amount of money standing to the credit of that account is insufficient to honour the cheque or that it exceeds the amount arranged to be paid from that account by an agreement made with that bank, such person shall be deemed to have committed an offence and shall, without prejudice to any other provisions of this Act, be punished with imprisonment for a term which may be extended to two years, or with fine which may extend to twice the amount of the cheque, or with both:\n\nProvided that nothing contained in this section shall apply unless: (a) Cheque presented within 3 months; (b) Demand notice issued within 30 days of dishonour memo; (c) Drawer fails to pay within 15 days of notice receipt.',
          explanation:
              'Quasi-criminal offence to enforce credibility of commercial cheques. Requires statutory 15 days demand notice before complaint can be filed.',
          punishment: 'Imprisonment up to 2 Years, or Fine up to Twice the Cheque Amount, or Both',
          bailable: true,
          cognizable: false,
          triableBy: 'Judicial Magistrate First Class / Metropolitan Magistrate',
          examples: [
            'Practical Example 1: Merchant A issues cheque of ₹5 Lakhs to B for supply of goods. Bank returns cheque with memo "Funds Insufficient". B sends statutory legal demand notice within 20 days. A receives notice but fails to pay within 15 days. On the 16th day, cause of action arises, and B files Section 138 complaint within 30 days.',
          ],
          keyIngredients: [
            'Cheque drawn for discharge of legally enforceable debt or liability.',
            'Presentation to bank within validity period (3 months).',
            'Dishonour due to insufficient funds or account limits.',
            'Statutory written demand notice issued within 30 days of receiving bank return memo.',
            'Failure of drawer to make payment within 15 days of receiving notice.',
            'Complaint filed within 1 month from expiry of 15-day notice period.',
          ],
          landmarkCases: [
            'Dashrath Rupsingh Rathod v. State of Maharashtra (2014) 9 SCC 129 - Territorial jurisdiction in cheque bounce cases (subsequently codified under Sec 142(2)).',
            'Rangappa v. Sri Mohan (2010) 11 SCC 441 - Presumption of legally enforceable debt under Section 139 is mandatory.',
            'Meters and Instruments Pvt. Ltd. v. Kanchan Mehta (2018) 1 SCC 560 - Section 138 offence is primarily a civil wrong clothed in criminal contours.',
          ],
          examTips:
              'Mains Favorite: Explain the statutory timeline of Section 138: (1) 3 months cheque validity, (2) 30 days notice to drawer, (3) 15 days to pay, (4) 30 days limitation to file complaint.',
        ),
        Section(
          sectionNumber: '139',
          chapter: 'Chapter XVII - Of Penalties in case of Dishonour of Certain Cheques',
          title: 'Presumption in favour of holder',
          content:
              'It shall be presumed, unless the contrary is proved, that the holder of a cheque received the cheque of the nature referred to in section 138 for the discharge, in whole or in part, of any debt or other liability.',
          explanation:
              'Rebuttable reverse-burden presumption of law. Once execution and signature of the cheque is admitted by the accused, the Court MUST presume that it was issued for a valid existing debt.',
          punishment: 'Evidentiary Presumption',
          bailable: true,
          cognizable: false,
          triableBy: 'Magistrate Court',
          examples: [
            'Practical Example 1: Accused admits signing cheque of ₹10 Lakhs but claims it was a blank security cheque given for a friendship loan. Because signature is admitted, Section 139 presumption activates. Accused must raise a probable defence by preponderance of probabilities to rebut the presumption.',
          ],
          keyIngredients: [
            'Statutory presumption of law (not discretion of court).',
            'Rebuttable by accused on standard of preponderance of probabilities (accused need not prove beyond reasonable doubt).',
            'Covers existence of legally enforceable debt.',
          ],
          landmarkCases: [
            'Rangappa v. Sri Mohan (2010) 11 SCC 441 - Reverse onus clause; standard of proof to rebut presumption is preponderance of probabilities.',
            'Bir Singh v. Mukesh Kumar (2019) 4 SCC 197 - Blank signed cheque filled by payee does not invalidate Section 139 presumption.',
          ],
          examTips:
              'High frequency Mains question: How can an accused rebut the statutory presumption under Section 139 NI Act? Cite Rangappa and Basalingappa v Mudibasappa (2019).',
        ),
      ],
    ),
    BareAct(
      id: 'tpa',
      title: 'Transfer of Property Act, 1882',
      shortTitle: 'Property Law (TPA)',
      enactmentYear: 1882,
      category: 'Property Law (Minor Act)',
      isMinor: true,
      totalSections: 137,
      description:
          'Governs inter vivos transfers of immovable property. Includes sales, gifts, mortgages (Sec 58), leases (Sec 105), actionable claims, and the Doctrine of Lis Pendens (Sec 52).',
      sections: [
        Section(
          sectionNumber: '52',
          chapter: 'Chapter II - Of Transfers of Property by Act of Parties',
          title: 'Transfer of property pending suit relating thereto (Doctrine of Lis Pendens)',
          content:
              'During the pendency in any Court having authority within the limits of India... of any suit or proceeding which is not collusive and in which any right to immovable property is directly and substantially in question, the property cannot be transferred or otherwise dealt with by any party to the suit or proceeding so as to affect the rights of any other party thereto under any decree or order which may be made therein, except under the authority of the Court and on such terms as it may impose.',
          explanation:
              'Based on Latin maxim: "Pendente lite nihil innovetur" (During litigation, nothing new should be introduced). Transfers made during suit pendency are not void, but are strictly subordinate to the final court decree.',
          punishment: 'Decree Binds Transferee',
          bailable: true,
          cognizable: false,
          triableBy: 'Civil Courts',
          examples: [
            'Practical Example 1: Plaintiff P sues D claiming title to ancestral Haveli. While the suit is pending in Civil Court, D sells the Haveli to third-party buyer B for ₹50 Lakhs. The Court eventually decrees the suit in favour of P. Buyer B is bound by the decree and must surrender the Haveli to P under Section 52.',
          ],
          keyIngredients: [
            'Pendency of a suit or legal proceeding in a competent court.',
            'Suit must NOT be collusive.',
            'Right to specific immovable property directly and substantially in issue.',
            'Transfer executed by a party to the suit without court permission.',
            'Transfer is subordinate to the rights determined by the final decree.',
          ],
          landmarkCases: [
            'Bellamy v. Sabine (1857) 1 De G & J 566 - Foundational English ruling on Lis Pendens rationale.',
            'Kedar Nath Lal v. Sheonarain (1969) 2 SCC 787 - Lis Pendens applies to voluntary as well as involuntary court auction sales.',
          ],
          examTips:
              'Essential for PCS-J Mains: Does Section 52 render a pendente lite transfer completely void? NO! The transfer is valid between transferor and transferee, but subordinate to the court\'s decree.',
        ),
        Section(
          sectionNumber: '53A',
          chapter: 'Chapter II - Of Transfers of Property by Act of Parties',
          title: 'Part performance',
          content:
              'Where any person contracts to transfer for consideration any immovable property by writing signed by him or on his behalf from which the terms necessary to constitute the transfer can be ascertained with reasonable certainty, and the transferee has, in part performance of the contract, taken possession of the property or any part thereof... and the transferee has performed or is willing to perform his part of the contract... then, notwithstanding that the instrument of transfer, though required to be registered, has not been registered... the transferor or any person claiming under him shall be debarred from enforcing against the transferee... any right in respect of the property.',
          explanation:
              'Equitable shield: "Part performance can be used as a shield, but NOT as a sword." Protects transferees who have taken possession and paid consideration under an unregistered written contract against ejectment by the transferor.',
          punishment: 'Equitable Defence / Injunction Against Eviction',
          bailable: true,
          cognizable: false,
          triableBy: 'Civil Courts',
          examples: [
            'Practical Example 1: Owner O signs written agreement to sell land to B for ₹20 Lakhs. B pays full ₹20 Lakhs and takes physical possession. Formal sale deed is not registered. 2 years later, O files suit to evict B on the ground that title has not passed due to non-registration. B successfully defends using Section 53A as a shield.',
          ],
          keyIngredients: [
            'Contract to transfer immovable property for consideration.',
            'Agreement must be in writing and signed by transferor.',
            'Transferee has taken physical possession in part performance.',
            'Transferee has performed or is willing to perform his obligations.',
            'Can only be used as a defence (Shield), not to claim affirmative title (Sword).',
          ],
          landmarkCases: [
            'Mohammad Musa v. Aghore Kumar Ganguli (1914) 42 IA 1 - Early application of equitable part performance in India.',
            'Shrimant Shamrao Suryavanshi v. Pralhad Bhairoba Suryavanshi (2002) 3 SCC 676 - Explaining the 6 conditions of Section 53A.',
          ],
          examTips:
              'Mains Maxim: "Doctrine of Part Performance is a shield, not a sword." Explain with reference to registration requirements and Section 53A TPA.',
        ),
        Section(
          sectionNumber: '58',
          chapter: 'Chapter IV - Of Mortgages of Immovable Property and Charges',
          title: 'Mortgage defined & 6 kinds of mortgage',
          content:
              'A mortgage is the transfer of an interest in specific immovable property for the purpose of securing the payment of money advanced or to be advanced by way of loan, an existing or future debt, or the performance of an engagement which may give rise to a pecuniary liability.\n\nClasses of Mortgages:\n(a) Simple mortgage;\n(b) Mortgage by conditional sale;\n(c) Usufructuary mortgage;\n(d) English mortgage;\n(e) Mortgage by deposit of title-deeds (Equitable mortgage);\n(f) Anomalous mortgage.',
          explanation:
              'Transfer of an interest (not absolute ownership) to secure a loan. Distinguishes 6 statutory kinds of mortgages in Indian law.',
          punishment: 'Security of Debt / Foreclosure or Sale Decree',
          bailable: true,
          cognizable: false,
          triableBy: 'Civil Courts',
          examples: [
            'Practical Example 1: Borrower B takes ₹20 Lakhs business loan from Bank and deposits original title deed of his house in Mumbai. No formal mortgage deed is registered. This creates a valid "Mortgage by Deposit of Title Deeds" under Section 58(f).',
          ],
          keyIngredients: [
            'Transfer of interest in specific immovable property.',
            'Purpose: To secure repayment of debt/loan.',
            'Mortgagor retains right of redemption under Section 60 ("Once a mortgage, always a mortgage").',
          ],
          landmarkCases: [
            'Stanley v. Wilde (1899) 2 Ch 474 - "A mortgage is a conveyance of land or an assignment of chattels as security for the payment of a debt."',
            'Ganga Dhar v. Shankar Lal (1959) SCR 509 - Clog on redemption is void.',
          ],
          examTips:
              'High frequency Mains topic: "Once a mortgage, always a mortgage, and nothing but a mortgage." Discuss the doctrine of Clog on Equity of Redemption under Section 60.',
        ),
      ],
    ),
    BareAct(
      id: 'pocso',
      title: 'Protection of Children from Sexual Offences Act, 2012',
      shortTitle: 'POCSO Act, 2012',
      enactmentYear: 2012,
      category: 'Criminal Law (Minor Act)',
      isMinor: true,
      totalSections: 46,
      description:
          'Special child-centric penal statute to protect children below 18 years from sexual offences, pornography, and assault with child-friendly trial procedures and mandatory reporting.',
      sections: [
        Section(
          sectionNumber: '5 & 6',
          chapter: 'Chapter II - Sexual Offences Against Children',
          title: 'Aggravated Penetrative Sexual Assault and Punishment',
          content:
              'Section 5 defines aggravated penetrative sexual assault (committed by police officer, armed personnel, public servant, family member, teacher, doctor, or during gang assault, or causing grievous hurt/pregnancy).\n\nSection 6 Punishment: Whoever commits aggravated penetrative sexual assault shall be punished with rigorous imprisonment for a term which shall not be less than twenty years, but which may extend to imprisonment for life, which shall mean imprisonment for the remainder of that natural life, and with fine, or with death.',
          explanation:
              'Stringent statutory minimum sentence of 20 years up to Life Imprisonment (remainder of natural life) or Death penalty for aggravated assault on children.',
          punishment: 'Rigorous Imprisonment 20 Years to Life (Remainder of Natural Life) or Death, and Fine',
          bailable: false,
          cognizable: true,
          triableBy: 'Special POCSO Court',
          examples: [
            'Practical Example 1: A school teacher commits sexual assault on a 10-year-old student inside school premises. Because the accused is in a position of trust and authority (teacher), the offence falls under Section 5(f) and attracts minimum 20 years rigorous imprisonment under Section 6.',
          ],
          keyIngredients: [
            'Victim is a child (person under 18 years of age as per Section 2(1)(d)).',
            'Penetrative sexual assault committed under aggravated circumstances defined in Section 5.',
            'Gender-neutral offence protecting both male and female children.',
          ],
          landmarkCases: [
            'Eera v. State (NCT of Delhi) (2017) 15 SCC 133 - Purposive interpretation of child protection under POCSO Act.',
            'Attorney General for India v. Satish (2022) 5 SCC 545 - Supreme Court held "skin-to-skin" physical contact is NOT required to constitute sexual assault under POCSO.',
          ],
          examTips:
              'Mains Alert: Discuss the landmark ruling in Attorney General v. Satish overturning Bombay HC "skin to skin" contact judgment. Emphasize gender neutrality of POCSO.',
        ),
        Section(
          sectionNumber: '29 & 30',
          chapter: 'Chapter VI - Procedure and Powers of Special Courts',
          title: 'Presumption as to certain offences & Culpable mental state',
          content:
              'Section 29: Where a person is prosecuted for committing or abetting or attempting to commit any offence under section 3, 5, 7 and section 9, the Special Court shall presume, that such person has committed or abetted or attempted to commit the offence, as the case may be unless the contrary is proved.\n\nSection 30: In any prosecution for any offence under this Act which requires a culpable mental state on the part of the accused, the Special Court shall presume the existence of such mental state.',
          explanation:
              'Reverse burden of proof! Once prosecution establishes foundational facts of the act, the Court MUST presume that the accused committed the offence and possessed culpable mens rea. The accused must rebut this presumption.',
          punishment: 'Statutory Reverse Burden of Proof',
          bailable: false,
          cognizable: true,
          triableBy: 'Special Court',
          examples: [
            'Practical Example 1: In a trial under POCSO Section 5, prosecution establishes child testimony and medical examination showing assault. Under Section 29, the Court presumes guilt unless the accused proves innocence by preponderance of probabilities.',
          ],
          keyIngredients: [
            'Mandatory presumption ("shall presume").',
            'Applies to Section 3, 5, 7, and 9 prosecution.',
            'Presumption of culpable mental state under Section 30.',
            'Rebuttable by defence.',
          ],
          landmarkCases: [
            'State of Bihar v. Rajballav Prasad (2017) 2 SCC 178 - Balancing Section 29 presumption with fair trial rights of accused.',
          ],
          examTips:
              'Constitutional Law & Evidence Paper Favorite: How does Section 29 POCSO harmonize with Article 21 presumption of innocence?',
        ),
      ],
    ),
    BareAct(
      id: 'arbitration',
      title: 'Arbitration and Conciliation Act, 1996',
      shortTitle: 'Arbitration Act',
      enactmentYear: 1996,
      category: 'Commercial Law (Minor Act)',
      isMinor: true,
      totalSections: 86,
      description:
          'Based on UNCITRAL Model Law. Covers domestic arbitration, international commercial arbitration, minimal judicial intervention, and setting aside awards under Section 34.',
      sections: [
        Section(
          sectionNumber: '8',
          chapter: 'Part I - Arbitration, Chapter II',
          title: 'Power to refer parties to arbitration where there is an arbitration agreement',
          content:
              'A judicial authority, before which an action is brought in a matter which is the subject of an arbitration agreement shall, if a party to the arbitration agreement or any person claiming through or under him, so applies not later than the date of submitting his first statement on the substance of the dispute, refer the parties to arbitration unless it finds that prima facie no valid arbitration agreement exists.',
          explanation:
              'Mandatory reference to arbitration! Courts must refrain from entertaining civil suits where valid arbitration agreement exists, provided application is made before submitting written statement.',
          punishment: 'Reference to Arbitral Tribunal / Bar on Civil Suit',
          bailable: true,
          cognizable: false,
          triableBy: 'Civil Courts / Commercial Courts',
          examples: [
            'Practical Example 1: Party A sues Party B in Civil Court over software development contract. The contract contains an arbitration clause. Before filing written statement, B files Section 8 application. The Court MUST refer the dispute to arbitration and terminate civil suit proceedings.',
          ],
          keyIngredients: [
            'Valid arbitration agreement in writing under Section 7.',
            'Application filed by party not later than submitting first statement on substance of dispute.',
            'Court scope limited to prima facie examination of agreement validity.',
          ],
          landmarkCases: [
            'Vidya Drolia v. Durga Trading Corpn. (2021) 2 SCC 1 - Four-fold test of non-arbitrability of disputes.',
            'NN Global Mercantile v. Indo Unique Flame Ltd. (2023) 7-Judge Bench ruling on unstamped arbitration agreements.',
          ],
          examTips:
              'Commercial Law Paper: Discuss the 4-fold test of arbitrability laid down in Vidya Drolia.',
        ),
        Section(
          sectionNumber: '34',
          chapter: 'Chapter VII - Recourse Against Arbitral Award',
          title: 'Application for setting aside arbitral award',
          content:
              'Recourse to a Court against an arbitral award may be made only by an application for setting aside such award in accordance with sub-section (2) and sub-section (3).\n\nGrounds: (a) Incapacity of party; (b) Invalidity of agreement; (c) Lack of proper notice or unable to present case; (d) Award beyond scope of submission; (e) Arbitral composition not in accordance with agreement;\n\nSub-section (2)(b): Court finds that dispute is not arbitrable or award is in conflict with the public policy of India (fraud, fundamental policy of Indian law, or basic notions of morality/justice).\n\nSub-section (2A): Award arising out of domestic arbitration may also be set aside on ground of patent illegality appearing on the face of the award.',
          explanation:
              'Strict and exhaustive grounds for setting aside arbitral awards. Courts do NOT sit as courts of appeal and cannot re-appreciate evidence.',
          punishment: 'Setting Aside Arbitral Award',
          bailable: true,
          cognizable: false,
          triableBy: 'Principal Civil Court of Original Jurisdiction / High Court',
          examples: [
            'Practical Example 1: Arbitrator passes award granting damages based on an expired contract clause without giving respondent any hearing or notice. The High Court sets aside the award under Section 34(2)(a)(iii) for violation of natural justice.',
          ],
          keyIngredients: [
            'Exhaustive statutory grounds (no merit re-examination allowed).',
            'Patent illegality ground applies ONLY to domestic arbitrations under Section 34(2A).',
            'Limitation: 3 months, extendable by 30 days maximum under Section 34(3).',
          ],
          landmarkCases: [
            'Associate Builders v. DDA (2015) 3 SCC 49 - Definitive test of "Public Policy of India" and patent illegality.',
            'Ssangyong Engineering & Construction Co. Ltd. v. NHAI (2019) 15 SCC 131 - Post-2015 amendment interpretation of Section 34.',
          ],
          examTips:
              'High frequency question: Can a Court modify an arbitral award under Section 34? (Project Director, NHAI v M. Hakeem 2021: Supreme Court held Courts CANNOT modify awards under Section 34, only set aside or uphold).',
        ),
      ],
    ),
    BareAct(
      id: 'jj_act',
      title: 'Juvenile Justice (Care and Protection of Children) Act, 2015',
      shortTitle: 'JJ Act, 2015',
      enactmentYear: 2015,
      category: 'Criminal Law (Minor Act)',
      isMinor: true,
      totalSections: 112,
      description:
          'Comprehensive legislation for care, protection, and rehabilitation of children. Introduced preliminary assessment for children aged 16-18 years who commit heinous offences (Sec 15).',
      sections: [
        Section(
          sectionNumber: '15',
          chapter: 'Chapter IV - Procedure in Relation to Children in Conflict with Law',
          title: 'Preliminary assessment into heinous offences by Juvenile Justice Board',
          content:
              'In case of a heinous offence alleged to have been committed by a child, who has completed or is above the age of sixteen years, the Board shall conduct a preliminary assessment with regard to his mental and physical capacity to commit such offence, ability to understand the consequences of the offence and the circumstances in which he allegedly committed the offence, and may pass an order in accordance with the provisions of sub-section (3) of section 18:\n\nProvided that for such an assessment, the Board may take the assistance of experienced psychologists or psycho-social workers or other experts.',
          explanation:
              'Permits trial of children between 16 to 18 years as adults before Children\'s Court if preliminary assessment finds capacity and understanding of heinous offence.',
          punishment: 'Transfer to Children\'s Court or JJB Rehabilitation',
          bailable: true,
          cognizable: true,
          triableBy: 'Juvenile Justice Board (JJB)',
          examples: [
            'Practical Example 1: A 17-year-old youth commits pre-meditated murder. JJB conducts preliminary assessment with clinical psychologist under Section 15. Finding the youth fully mature and aware of consequences, JJB transfers case to Children\'s Court to be tried as an adult.',
          ],
          keyIngredients: [
            'Child must be between 16 and 18 years of age at the time of offence.',
            'Offence must be "heinous" (punishable with minimum 7 years imprisonment).',
            'JJB evaluates mental/physical capacity, consequence comprehension, and circumstances.',
            'Conducted within 3 months of child production.',
          ],
          landmarkCases: [
            'Barun Chandra Thakur v. Master Bholu (2022) SCC OnLine SC 870 - Supreme Court issued mandatory guidelines for preliminary assessment under Section 15.',
          ],
          examTips:
              'Key DJS Question: What is the procedure and consequence of preliminary assessment under Section 15 JJ Act?',
        ),
      ],
    ),
  ];
}
