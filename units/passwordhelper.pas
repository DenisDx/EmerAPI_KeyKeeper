unit PasswordHelper;

{$mode objfpc}{$H+}


interface

uses
  Classes, SysUtils;

var
  bip0039english:array[0..2047] of string=(
  'abandon',
  'ability',
  'able',
  'about',
  'above',
  'absent',
  'absorb',
  'abstract',
  'absurd',
  'abuse',
  'access',
  'accident',
  'account',
  'accuse',
  'achieve',
  'acid',
  'acoustic',
  'acquire',
  'across',
  'act',
  'action',
  'actor',
  'actress',
  'actual',
  'adapt',
  'add',
  'addict',
  'address',
  'adjust',
  'admit',
  'adult',
  'advance',
  'advice',
  'aerobic',
  'affair',
  'afford',
  'afraid',
  'again',
  'age',
  'agent',
  'agree',
  'ahead',
  'aim',
  'air',
  'airport',
  'aisle',
  'alarm',
  'album',
  'alcohol',
  'alert',
  'alien',
  'all',
  'alley',
  'allow',
  'almost',
  'alone',
  'alpha',
  'already',
  'also',
  'alter',
  'always',
  'amateur',
  'amazing',
  'among',
  'amount',
  'amused',
  'analyst',
  'anchor',
  'ancient',
  'anger',
  'angle',
  'angry',
  'animal',
  'ankle',
  'announce',
  'annual',
  'another',
  'answer',
  'antenna',
  'antique',
  'anxiety',
  'any',
  'apart',
  'apology',
  'appear',
  'apple',
  'approve',
  'april',
  'arch',
  'arctic',
  'area',
  'arena',
  'argue',
  'arm',
  'armed',
  'armor',
  'army',
  'around',
  'arrange',
  'arrest',
  'arrive',
  'arrow',
  'art',
  'artefact',
  'artist',
  'artwork',
  'ask',
  'aspect',
  'assault',
  'asset',
  'assist',
  'assume',
  'asthma',
  'athlete',
  'atom',
  'attack',
  'attend',
  'attitude',
  'attract',
  'auction',
  'audit',
  'august',
  'aunt',
  'author',
  'auto',
  'autumn',
  'average',
  'avocado',
  'avoid',
  'awake',
  'aware',
  'away',
  'awesome',
  'awful',
  'awkward',
  'axis',
  'baby',
  'bachelor',
  'bacon',
  'badge',
  'bag',
  'balance',
  'balcony',
  'ball',
  'bamboo',
  'banana',
  'banner',
  'bar',
  'barely',
  'bargain',
  'barrel',
  'base',
  'basic',
  'basket',
  'battle',
  'beach',
  'bean',
  'beauty',
  'because',
  'become',
  'beef',
  'before',
  'begin',
  'behave',
  'behind',
  'believe',
  'below',
  'belt',
  'bench',
  'benefit',
  'best',
  'betray',
  'better',
  'between',
  'beyond',
  'bicycle',
  'bid',
  'bike',
  'bind',
  'biology',
  'bird',
  'birth',
  'bitter',
  'black',
  'blade',
  'blame',
  'blanket',
  'blast',
  'bleak',
  'bless',
  'blind',
  'blood',
  'blossom',
  'blouse',
  'blue',
  'blur',
  'blush',
  'board',
  'boat',
  'body',
  'boil',
  'bomb',
  'bone',
  'bonus',
  'book',
  'boost',
  'border',
  'boring',
  'borrow',
  'boss',
  'bottom',
  'bounce',
  'box',
  'boy',
  'bracket',
  'brain',
  'brand',
  'brass',
  'brave',
  'bread',
  'breeze',
  'brick',
  'bridge',
  'brief',
  'bright',
  'bring',
  'brisk',
  'broccoli',
  'broken',
  'bronze',
  'broom',
  'brother',
  'brown',
  'brush',
  'bubble',
  'buddy',
  'budget',
  'buffalo',
  'build',
  'bulb',
  'bulk',
  'bullet',
  'bundle',
  'bunker',
  'burden',
  'burger',
  'burst',
  'bus',
  'business',
  'busy',
  'butter',
  'buyer',
  'buzz',
  'cabbage',
  'cabin',
  'cable',
  'cactus',
  'cage',
  'cake',
  'call',
  'calm',
  'camera',
  'camp',
  'can',
  'canal',
  'cancel',
  'candy',
  'cannon',
  'canoe',
  'canvas',
  'canyon',
  'capable',
  'capital',
  'captain',
  'car',
  'carbon',
  'card',
  'cargo',
  'carpet',
  'carry',
  'cart',
  'case',
  'cash',
  'casino',
  'castle',
  'casual',
  'cat',
  'catalog',
  'catch',
  'category',
  'cattle',
  'caught',
  'cause',
  'caution',
  'cave',
  'ceiling',
  'celery',
  'cement',
  'census',
  'century',
  'cereal',
  'certain',
  'chair',
  'chalk',
  'champion',
  'change',
  'chaos',
  'chapter',
  'charge',
  'chase',
  'chat',
  'cheap',
  'check',
  'cheese',
  'chef',
  'cherry',
  'chest',
  'chicken',
  'chief',
  'child',
  'chimney',
  'choice',
  'choose',
  'chronic',
  'chuckle',
  'chunk',
  'churn',
  'cigar',
  'cinnamon',
  'circle',
  'citizen',
  'city',
  'civil',
  'claim',
  'clap',
  'clarify',
  'claw',
  'clay',
  'clean',
  'clerk',
  'clever',
  'click',
  'client',
  'cliff',
  'climb',
  'clinic',
  'clip',
  'clock',
  'clog',
  'close',
  'cloth',
  'cloud',
  'clown',
  'club',
  'clump',
  'cluster',
  'clutch',
  'coach',
  'coast',
  'coconut',
  'code',
  'coffee',
  'coil',
  'coin',
  'collect',
  'color',
  'column',
  'combine',
  'come',
  'comfort',
  'comic',
  'common',
  'company',
  'concert',
  'conduct',
  'confirm',
  'congress',
  'connect',
  'consider',
  'control',
  'convince',
  'cook',
  'cool',
  'copper',
  'copy',
  'coral',
  'core',
  'corn',
  'correct',
  'cost',
  'cotton',
  'couch',
  'country',
  'couple',
  'course',
  'cousin',
  'cover',
  'coyote',
  'crack',
  'cradle',
  'craft',
  'cram',
  'crane',
  'crash',
  'crater',
  'crawl',
  'crazy',
  'cream',
  'credit',
  'creek',
  'crew',
  'cricket',
  'crime',
  'crisp',
  'critic',
  'crop',
  'cross',
  'crouch',
  'crowd',
  'crucial',
  'cruel',
  'cruise',
  'crumble',
  'crunch',
  'crush',
  'cry',
  'crystal',
  'cube',
  'culture',
  'cup',
  'cupboard',
  'curious',
  'current',
  'curtain',
  'curve',
  'cushion',
  'custom',
  'cute',
  'cycle',
  'dad',
  'damage',
  'damp',
  'dance',
  'danger',
  'daring',
  'dash',
  'daughter',
  'dawn',
  'day',
  'deal',
  'debate',
  'debris',
  'decade',
  'december',
  'decide',
  'decline',
  'decorate',
  'decrease',
  'deer',
  'defense',
  'define',
  'defy',
  'degree',
  'delay',
  'deliver',
  'demand',
  'demise',
  'denial',
  'dentist',
  'deny',
  'depart',
  'depend',
  'deposit',
  'depth',
  'deputy',
  'derive',
  'describe',
  'desert',
  'design',
  'desk',
  'despair',
  'destroy',
  'detail',
  'detect',
  'develop',
  'device',
  'devote',
  'diagram',
  'dial',
  'diamond',
  'diary',
  'dice',
  'diesel',
  'diet',
  'differ',
  'digital',
  'dignity',
  'dilemma',
  'dinner',
  'dinosaur',
  'direct',
  'dirt',
  'disagree',
  'discover',
  'disease',
  'dish',
  'dismiss',
  'disorder',
  'display',
  'distance',
  'divert',
  'divide',
  'divorce',
  'dizzy',
  'doctor',
  'document',
  'dog',
  'doll',
  'dolphin',
  'domain',
  'donate',
  'donkey',
  'donor',
  'door',
  'dose',
  'double',
  'dove',
  'draft',
  'dragon',
  'drama',
  'drastic',
  'draw',
  'dream',
  'dress',
  'drift',
  'drill',
  'drink',
  'drip',
  'drive',
  'drop',
  'drum',
  'dry',
  'duck',
  'dumb',
  'dune',
  'during',
  'dust',
  'dutch',
  'duty',
  'dwarf',
  'dynamic',
  'eager',
  'eagle',
  'early',
  'earn',
  'earth',
  'easily',
  'east',
  'easy',
  'echo',
  'ecology',
  'economy',
  'edge',
  'edit',
  'educate',
  'effort',
  'egg',
  'eight',
  'either',
  'elbow',
  'elder',
  'electric',
  'elegant',
  'element',
  'elephant',
  'elevator',
  'elite',
  'else',
  'embark',
  'embody',
  'embrace',
  'emerge',
  'emotion',
  'employ',
  'empower',
  'empty',
  'enable',
  'enact',
  'end',
  'endless',
  'endorse',
  'enemy',
  'energy',
  'enforce',
  'engage',
  'engine',
  'enhance',
  'enjoy',
  'enlist',
  'enough',
  'enrich',
  'enroll',
  'ensure',
  'enter',
  'entire',
  'entry',
  'envelope',
  'episode',
  'equal',
  'equip',
  'era',
  'erase',
  'erode',
  'erosion',
  'error',
  'erupt',
  'escape',
  'essay',
  'essence',
  'estate',
  'eternal',
  'ethics',
  'evidence',
  'evil',
  'evoke',
  'evolve',
  'exact',
  'example',
  'excess',
  'exchange',
  'excite',
  'exclude',
  'excuse',
  'execute',
  'exercise',
  'exhaust',
  'exhibit',
  'exile',
  'exist',
  'exit',
  'exotic',
  'expand',
  'expect',
  'expire',
  'explain',
  'expose',
  'express',
  'extend',
  'extra',
  'eye',
  'eyebrow',
  'fabric',
  'face',
  'faculty',
  'fade',
  'faint',
  'faith',
  'fall',
  'false',
  'fame',
  'family',
  'famous',
  'fan',
  'fancy',
  'fantasy',
  'farm',
  'fashion',
  'fat',
  'fatal',
  'father',
  'fatigue',
  'fault',
  'favorite',
  'feature',
  'february',
  'federal',
  'fee',
  'feed',
  'feel',
  'female',
  'fence',
  'festival',
  'fetch',
  'fever',
  'few',
  'fiber',
  'fiction',
  'field',
  'figure',
  'file',
  'film',
  'filter',
  'final',
  'find',
  'fine',
  'finger',
  'finish',
  'fire',
  'firm',
  'first',
  'fiscal',
  'fish',
  'fit',
  'fitness',
  'fix',
  'flag',
  'flame',
  'flash',
  'flat',
  'flavor',
  'flee',
  'flight',
  'flip',
  'float',
  'flock',
  'floor',
  'flower',
  'fluid',
  'flush',
  'fly',
  'foam',
  'focus',
  'fog',
  'foil',
  'fold',
  'follow',
  'food',
  'foot',
  'force',
  'forest',
  'forget',
  'fork',
  'fortune',
  'forum',
  'forward',
  'fossil',
  'foster',
  'found',
  'fox',
  'fragile',
  'frame',
  'frequent',
  'fresh',
  'friend',
  'fringe',
  'frog',
  'front',
  'frost',
  'frown',
  'frozen',
  'fruit',
  'fuel',
  'fun',
  'funny',
  'furnace',
  'fury',
  'future',
  'gadget',
  'gain',
  'galaxy',
  'gallery',
  'game',
  'gap',
  'garage',
  'garbage',
  'garden',
  'garlic',
  'garment',
  'gas',
  'gasp',
  'gate',
  'gather',
  'gauge',
  'gaze',
  'general',
  'genius',
  'genre',
  'gentle',
  'genuine',
  'gesture',
  'ghost',
  'giant',
  'gift',
  'giggle',
  'ginger',
  'giraffe',
  'girl',
  'give',
  'glad',
  'glance',
  'glare',
  'glass',
  'glide',
  'glimpse',
  'globe',
  'gloom',
  'glory',
  'glove',
  'glow',
  'glue',
  'goat',
  'goddess',
  'gold',
  'good',
  'goose',
  'gorilla',
  'gospel',
  'gossip',
  'govern',
  'gown',
  'grab',
  'grace',
  'grain',
  'grant',
  'grape',
  'grass',
  'gravity',
  'great',
  'green',
  'grid',
  'grief',
  'grit',
  'grocery',
  'group',
  'grow',
  'grunt',
  'guard',
  'guess',
  'guide',
  'guilt',
  'guitar',
  'gun',
  'gym',
  'habit',
  'hair',
  'half',
  'hammer',
  'hamster',
  'hand',
  'happy',
  'harbor',
  'hard',
  'harsh',
  'harvest',
  'hat',
  'have',
  'hawk',
  'hazard',
  'head',
  'health',
  'heart',
  'heavy',
  'hedgehog',
  'height',
  'hello',
  'helmet',
  'help',
  'hen',
  'hero',
  'hidden',
  'high',
  'hill',
  'hint',
  'hip',
  'hire',
  'history',
  'hobby',
  'hockey',
  'hold',
  'hole',
  'holiday',
  'hollow',
  'home',
  'honey',
  'hood',
  'hope',
  'horn',
  'horror',
  'horse',
  'hospital',
  'host',
  'hotel',
  'hour',
  'hover',
  'hub',
  'huge',
  'human',
  'humble',
  'humor',
  'hundred',
  'hungry',
  'hunt',
  'hurdle',
  'hurry',
  'hurt',
  'husband',
  'hybrid',
  'ice',
  'icon',
  'idea',
  'identify',
  'idle',
  'ignore',
  'ill',
  'illegal',
  'illness',
  'image',
  'imitate',
  'immense',
  'immune',
  'impact',
  'impose',
  'improve',
  'impulse',
  'inch',
  'include',
  'income',
  'increase',
  'index',
  'indicate',
  'indoor',
  'industry',
  'infant',
  'inflict',
  'inform',
  'inhale',
  'inherit',
  'initial',
  'inject',
  'injury',
  'inmate',
  'inner',
  'innocent',
  'input',
  'inquiry',
  'insane',
  'insect',
  'inside',
  'inspire',
  'install',
  'intact',
  'interest',
  'into',
  'invest',
  'invite',
  'involve',
  'iron',
  'island',
  'isolate',
  'issue',
  'item',
  'ivory',
  'jacket',
  'jaguar',
  'jar',
  'jazz',
  'jealous',
  'jeans',
  'jelly',
  'jewel',
  'job',
  'join',
  'joke',
  'journey',
  'joy',
  'judge',
  'juice',
  'jump',
  'jungle',
  'junior',
  'junk',
  'just',
  'kangaroo',
  'keen',
  'keep',
  'ketchup',
  'key',
  'kick',
  'kid',
  'kidney',
  'kind',
  'kingdom',
  'kiss',
  'kit',
  'kitchen',
  'kite',
  'kitten',
  'kiwi',
  'knee',
  'knife',
  'knock',
  'know',
  'lab',
  'label',
  'labor',
  'ladder',
  'lady',
  'lake',
  'lamp',
  'language',
  'laptop',
  'large',
  'later',
  'latin',
  'laugh',
  'laundry',
  'lava',
  'law',
  'lawn',
  'lawsuit',
  'layer',
  'lazy',
  'leader',
  'leaf',
  'learn',
  'leave',
  'lecture',
  'left',
  'leg',
  'legal',
  'legend',
  'leisure',
  'lemon',
  'lend',
  'length',
  'lens',
  'leopard',
  'lesson',
  'letter',
  'level',
  'liar',
  'liberty',
  'library',
  'license',
  'life',
  'lift',
  'light',
  'like',
  'limb',
  'limit',
  'link',
  'lion',
  'liquid',
  'list',
  'little',
  'live',
  'lizard',
  'load',
  'loan',
  'lobster',
  'local',
  'lock',
  'logic',
  'lonely',
  'long',
  'loop',
  'lottery',
  'loud',
  'lounge',
  'love',
  'loyal',
  'lucky',
  'luggage',
  'lumber',
  'lunar',
  'lunch',
  'luxury',
  'lyrics',
  'machine',
  'mad',
  'magic',
  'magnet',
  'maid',
  'mail',
  'main',
  'major',
  'make',
  'mammal',
  'man',
  'manage',
  'mandate',
  'mango',
  'mansion',
  'manual',
  'maple',
  'marble',
  'march',
  'margin',
  'marine',
  'market',
  'marriage',
  'mask',
  'mass',
  'master',
  'match',
  'material',
  'math',
  'matrix',
  'matter',
  'maximum',
  'maze',
  'meadow',
  'mean',
  'measure',
  'meat',
  'mechanic',
  'medal',
  'media',
  'melody',
  'melt',
  'member',
  'memory',
  'mention',
  'menu',
  'mercy',
  'merge',
  'merit',
  'merry',
  'mesh',
  'message',
  'metal',
  'method',
  'middle',
  'midnight',
  'milk',
  'million',
  'mimic',
  'mind',
  'minimum',
  'minor',
  'minute',
  'miracle',
  'mirror',
  'misery',
  'miss',
  'mistake',
  'mix',
  'mixed',
  'mixture',
  'mobile',
  'model',
  'modify',
  'mom',
  'moment',
  'monitor',
  'monkey',
  'monster',
  'month',
  'moon',
  'moral',
  'more',
  'morning',
  'mosquito',
  'mother',
  'motion',
  'motor',
  'mountain',
  'mouse',
  'move',
  'movie',
  'much',
  'muffin',
  'mule',
  'multiply',
  'muscle',
  'museum',
  'mushroom',
  'music',
  'must',
  'mutual',
  'myself',
  'mystery',
  'myth',
  'naive',
  'name',
  'napkin',
  'narrow',
  'nasty',
  'nation',
  'nature',
  'near',
  'neck',
  'need',
  'negative',
  'neglect',
  'neither',
  'nephew',
  'nerve',
  'nest',
  'net',
  'network',
  'neutral',
  'never',
  'news',
  'next',
  'nice',
  'night',
  'noble',
  'noise',
  'nominee',
  'noodle',
  'normal',
  'north',
  'nose',
  'notable',
  'note',
  'nothing',
  'notice',
  'novel',
  'now',
  'nuclear',
  'number',
  'nurse',
  'nut',
  'oak',
  'obey',
  'object',
  'oblige',
  'obscure',
  'observe',
  'obtain',
  'obvious',
  'occur',
  'ocean',
  'october',
  'odor',
  'off',
  'offer',
  'office',
  'often',
  'oil',
  'okay',
  'old',
  'olive',
  'olympic',
  'omit',
  'once',
  'one',
  'onion',
  'online',
  'only',
  'open',
  'opera',
  'opinion',
  'oppose',
  'option',
  'orange',
  'orbit',
  'orchard',
  'order',
  'ordinary',
  'organ',
  'orient',
  'original',
  'orphan',
  'ostrich',
  'other',
  'outdoor',
  'outer',
  'output',
  'outside',
  'oval',
  'oven',
  'over',
  'own',
  'owner',
  'oxygen',
  'oyster',
  'ozone',
  'pact',
  'paddle',
  'page',
  'pair',
  'palace',
  'palm',
  'panda',
  'panel',
  'panic',
  'panther',
  'paper',
  'parade',
  'parent',
  'park',
  'parrot',
  'party',
  'pass',
  'patch',
  'path',
  'patient',
  'patrol',
  'pattern',
  'pause',
  'pave',
  'payment',
  'peace',
  'peanut',
  'pear',
  'peasant',
  'pelican',
  'pen',
  'penalty',
  'pencil',
  'people',
  'pepper',
  'perfect',
  'permit',
  'person',
  'pet',
  'phone',
  'photo',
  'phrase',
  'physical',
  'piano',
  'picnic',
  'picture',
  'piece',
  'pig',
  'pigeon',
  'pill',
  'pilot',
  'pink',
  'pioneer',
  'pipe',
  'pistol',
  'pitch',
  'pizza',
  'place',
  'planet',
  'plastic',
  'plate',
  'play',
  'please',
  'pledge',
  'pluck',
  'plug',
  'plunge',
  'poem',
  'poet',
  'point',
  'polar',
  'pole',
  'police',
  'pond',
  'pony',
  'pool',
  'popular',
  'portion',
  'position',
  'possible',
  'post',
  'potato',
  'pottery',
  'poverty',
  'powder',
  'power',
  'practice',
  'praise',
  'predict',
  'prefer',
  'prepare',
  'present',
  'pretty',
  'prevent',
  'price',
  'pride',
  'primary',
  'print',
  'priority',
  'prison',
  'private',
  'prize',
  'problem',
  'process',
  'produce',
  'profit',
  'program',
  'project',
  'promote',
  'proof',
  'property',
  'prosper',
  'protect',
  'proud',
  'provide',
  'public',
  'pudding',
  'pull',
  'pulp',
  'pulse',
  'pumpkin',
  'punch',
  'pupil',
  'puppy',
  'purchase',
  'purity',
  'purpose',
  'purse',
  'push',
  'put',
  'puzzle',
  'pyramid',
  'quality',
  'quantum',
  'quarter',
  'question',
  'quick',
  'quit',
  'quiz',
  'quote',
  'rabbit',
  'raccoon',
  'race',
  'rack',
  'radar',
  'radio',
  'rail',
  'rain',
  'raise',
  'rally',
  'ramp',
  'ranch',
  'random',
  'range',
  'rapid',
  'rare',
  'rate',
  'rather',
  'raven',
  'raw',
  'razor',
  'ready',
  'real',
  'reason',
  'rebel',
  'rebuild',
  'recall',
  'receive',
  'recipe',
  'record',
  'recycle',
  'reduce',
  'reflect',
  'reform',
  'refuse',
  'region',
  'regret',
  'regular',
  'reject',
  'relax',
  'release',
  'relief',
  'rely',
  'remain',
  'remember',
  'remind',
  'remove',
  'render',
  'renew',
  'rent',
  'reopen',
  'repair',
  'repeat',
  'replace',
  'report',
  'require',
  'rescue',
  'resemble',
  'resist',
  'resource',
  'response',
  'result',
  'retire',
  'retreat',
  'return',
  'reunion',
  'reveal',
  'review',
  'reward',
  'rhythm',
  'rib',
  'ribbon',
  'rice',
  'rich',
  'ride',
  'ridge',
  'rifle',
  'right',
  'rigid',
  'ring',
  'riot',
  'ripple',
  'risk',
  'ritual',
  'rival',
  'river',
  'road',
  'roast',
  'robot',
  'robust',
  'rocket',
  'romance',
  'roof',
  'rookie',
  'room',
  'rose',
  'rotate',
  'rough',
  'round',
  'route',
  'royal',
  'rubber',
  'rude',
  'rug',
  'rule',
  'run',
  'runway',
  'rural',
  'sad',
  'saddle',
  'sadness',
  'safe',
  'sail',
  'salad',
  'salmon',
  'salon',
  'salt',
  'salute',
  'same',
  'sample',
  'sand',
  'satisfy',
  'satoshi',
  'sauce',
  'sausage',
  'save',
  'say',
  'scale',
  'scan',
  'scare',
  'scatter',
  'scene',
  'scheme',
  'school',
  'science',
  'scissors',
  'scorpion',
  'scout',
  'scrap',
  'screen',
  'script',
  'scrub',
  'sea',
  'search',
  'season',
  'seat',
  'second',
  'secret',
  'section',
  'security',
  'seed',
  'seek',
  'segment',
  'select',
  'sell',
  'seminar',
  'senior',
  'sense',
  'sentence',
  'series',
  'service',
  'session',
  'settle',
  'setup',
  'seven',
  'shadow',
  'shaft',
  'shallow',
  'share',
  'shed',
  'shell',
  'sheriff',
  'shield',
  'shift',
  'shine',
  'ship',
  'shiver',
  'shock',
  'shoe',
  'shoot',
  'shop',
  'short',
  'shoulder',
  'shove',
  'shrimp',
  'shrug',
  'shuffle',
  'shy',
  'sibling',
  'sick',
  'side',
  'siege',
  'sight',
  'sign',
  'silent',
  'silk',
  'silly',
  'silver',
  'similar',
  'simple',
  'since',
  'sing',
  'siren',
  'sister',
  'situate',
  'six',
  'size',
  'skate',
  'sketch',
  'ski',
  'skill',
  'skin',
  'skirt',
  'skull',
  'slab',
  'slam',
  'sleep',
  'slender',
  'slice',
  'slide',
  'slight',
  'slim',
  'slogan',
  'slot',
  'slow',
  'slush',
  'small',
  'smart',
  'smile',
  'smoke',
  'smooth',
  'snack',
  'snake',
  'snap',
  'sniff',
  'snow',
  'soap',
  'soccer',
  'social',
  'sock',
  'soda',
  'soft',
  'solar',
  'soldier',
  'solid',
  'solution',
  'solve',
  'someone',
  'song',
  'soon',
  'sorry',
  'sort',
  'soul',
  'sound',
  'soup',
  'source',
  'south',
  'space',
  'spare',
  'spatial',
  'spawn',
  'speak',
  'special',
  'speed',
  'spell',
  'spend',
  'sphere',
  'spice',
  'spider',
  'spike',
  'spin',
  'spirit',
  'split',
  'spoil',
  'sponsor',
  'spoon',
  'sport',
  'spot',
  'spray',
  'spread',
  'spring',
  'spy',
  'square',
  'squeeze',
  'squirrel',
  'stable',
  'stadium',
  'staff',
  'stage',
  'stairs',
  'stamp',
  'stand',
  'start',
  'state',
  'stay',
  'steak',
  'steel',
  'stem',
  'step',
  'stereo',
  'stick',
  'still',
  'sting',
  'stock',
  'stomach',
  'stone',
  'stool',
  'story',
  'stove',
  'strategy',
  'street',
  'strike',
  'strong',
  'struggle',
  'student',
  'stuff',
  'stumble',
  'style',
  'subject',
  'submit',
  'subway',
  'success',
  'such',
  'sudden',
  'suffer',
  'sugar',
  'suggest',
  'suit',
  'summer',
  'sun',
  'sunny',
  'sunset',
  'super',
  'supply',
  'supreme',
  'sure',
  'surface',
  'surge',
  'surprise',
  'surround',
  'survey',
  'suspect',
  'sustain',
  'swallow',
  'swamp',
  'swap',
  'swarm',
  'swear',
  'sweet',
  'swift',
  'swim',
  'swing',
  'switch',
  'sword',
  'symbol',
  'symptom',
  'syrup',
  'system',
  'table',
  'tackle',
  'tag',
  'tail',
  'talent',
  'talk',
  'tank',
  'tape',
  'target',
  'task',
  'taste',
  'tattoo',
  'taxi',
  'teach',
  'team',
  'tell',
  'ten',
  'tenant',
  'tennis',
  'tent',
  'term',
  'test',
  'text',
  'thank',
  'that',
  'theme',
  'then',
  'theory',
  'there',
  'they',
  'thing',
  'this',
  'thought',
  'three',
  'thrive',
  'throw',
  'thumb',
  'thunder',
  'ticket',
  'tide',
  'tiger',
  'tilt',
  'timber',
  'time',
  'tiny',
  'tip',
  'tired',
  'tissue',
  'title',
  'toast',
  'tobacco',
  'today',
  'toddler',
  'toe',
  'together',
  'toilet',
  'token',
  'tomato',
  'tomorrow',
  'tone',
  'tongue',
  'tonight',
  'tool',
  'tooth',
  'top',
  'topic',
  'topple',
  'torch',
  'tornado',
  'tortoise',
  'toss',
  'total',
  'tourist',
  'toward',
  'tower',
  'town',
  'toy',
  'track',
  'trade',
  'traffic',
  'tragic',
  'train',
  'transfer',
  'trap',
  'trash',
  'travel',
  'tray',
  'treat',
  'tree',
  'trend',
  'trial',
  'tribe',
  'trick',
  'trigger',
  'trim',
  'trip',
  'trophy',
  'trouble',
  'truck',
  'true',
  'truly',
  'trumpet',
  'trust',
  'truth',
  'try',
  'tube',
  'tuition',
  'tumble',
  'tuna',
  'tunnel',
  'turkey',
  'turn',
  'turtle',
  'twelve',
  'twenty',
  'twice',
  'twin',
  'twist',
  'two',
  'type',
  'typical',
  'ugly',
  'umbrella',
  'unable',
  'unaware',
  'uncle',
  'uncover',
  'under',
  'undo',
  'unfair',
  'unfold',
  'unhappy',
  'uniform',
  'unique',
  'unit',
  'universe',
  'unknown',
  'unlock',
  'until',
  'unusual',
  'unveil',
  'update',
  'upgrade',
  'uphold',
  'upon',
  'upper',
  'upset',
  'urban',
  'urge',
  'usage',
  'use',
  'used',
  'useful',
  'useless',
  'usual',
  'utility',
  'vacant',
  'vacuum',
  'vague',
  'valid',
  'valley',
  'valve',
  'van',
  'vanish',
  'vapor',
  'various',
  'vast',
  'vault',
  'vehicle',
  'velvet',
  'vendor',
  'venture',
  'venue',
  'verb',
  'verify',
  'version',
  'very',
  'vessel',
  'veteran',
  'viable',
  'vibrant',
  'vicious',
  'victory',
  'video',
  'view',
  'village',
  'vintage',
  'violin',
  'virtual',
  'virus',
  'visa',
  'visit',
  'visual',
  'vital',
  'vivid',
  'vocal',
  'voice',
  'void',
  'volcano',
  'volume',
  'vote',
  'voyage',
  'wage',
  'wagon',
  'wait',
  'walk',
  'wall',
  'walnut',
  'want',
  'warfare',
  'warm',
  'warrior',
  'wash',
  'wasp',
  'waste',
  'water',
  'wave',
  'way',
  'wealth',
  'weapon',
  'wear',
  'weasel',
  'weather',
  'web',
  'wedding',
  'weekend',
  'weird',
  'welcome',
  'west',
  'wet',
  'whale',
  'what',
  'wheat',
  'wheel',
  'when',
  'where',
  'whip',
  'whisper',
  'wide',
  'width',
  'wife',
  'wild',
  'will',
  'win',
  'window',
  'wine',
  'wing',
  'wink',
  'winner',
  'winter',
  'wire',
  'wisdom',
  'wise',
  'wish',
  'witness',
  'wolf',
  'woman',
  'wonder',
  'wood',
  'wool',
  'word',
  'work',
  'world',
  'worry',
  'worth',
  'wrap',
  'wreck',
  'wrestle',
  'wrist',
  'write',
  'wrong',
  'yard',
  'year',
  'yellow',
  'you',
  'young',
  'youth',
  'zebra',
  'zero',
  'zone',
  'zoo'
  );
bip0039chinese:array[0..2047] of ansistring=(
  '的',
  '一',
  '是',
  '在',
  '不',
  '了',
  '有',
  '和',
  '人',
  '这',
  '中',
  '大',
  '为',
  '上',
  '个',
  '国',
  '我',
  '以',
  '要',
  '他',
  '时',
  '来',
  '用',
  '们',
  '生',
  '到',
  '作',
  '地',
  '于',
  '出',
  '就',
  '分',
  '对',
  '成',
  '会',
  '可',
  '主',
  '发',
  '年',
  '动',
  '同',
  '工',
  '也',
  '能',
  '下',
  '过',
  '子',
  '说',
  '产',
  '种',
  '面',
  '而',
  '方',
  '后',
  '多',
  '定',
  '行',
  '学',
  '法',
  '所',
  '民',
  '得',
  '经',
  '十',
  '三',
  '之',
  '进',
  '着',
  '等',
  '部',
  '度',
  '家',
  '电',
  '力',
  '里',
  '如',
  '水',
  '化',
  '高',
  '自',
  '二',
  '理',
  '起',
  '小',
  '物',
  '现',
  '实',
  '加',
  '量',
  '都',
  '两',
  '体',
  '制',
  '机',
  '当',
  '使',
  '点',
  '从',
  '业',
  '本',
  '去',
  '把',
  '性',
  '好',
  '应',
  '开',
  '它',
  '合',
  '还',
  '因',
  '由',
  '其',
  '些',
  '然',
  '前',
  '外',
  '天',
  '政',
  '四',
  '日',
  '那',
  '社',
  '义',
  '事',
  '平',
  '形',
  '相',
  '全',
  '表',
  '间',
  '样',
  '与',
  '关',
  '各',
  '重',
  '新',
  '线',
  '内',
  '数',
  '正',
  '心',
  '反',
  '你',
  '明',
  '看',
  '原',
  '又',
  '么',
  '利',
  '比',
  '或',
  '但',
  '质',
  '气',
  '第',
  '向',
  '道',
  '命',
  '此',
  '变',
  '条',
  '只',
  '没',
  '结',
  '解',
  '问',
  '意',
  '建',
  '月',
  '公',
  '无',
  '系',
  '军',
  '很',
  '情',
  '者',
  '最',
  '立',
  '代',
  '想',
  '已',
  '通',
  '并',
  '提',
  '直',
  '题',
  '党',
  '程',
  '展',
  '五',
  '果',
  '料',
  '象',
  '员',
  '革',
  '位',
  '入',
  '常',
  '文',
  '总',
  '次',
  '品',
  '式',
  '活',
  '设',
  '及',
  '管',
  '特',
  '件',
  '长',
  '求',
  '老',
  '头',
  '基',
  '资',
  '边',
  '流',
  '路',
  '级',
  '少',
  '图',
  '山',
  '统',
  '接',
  '知',
  '较',
  '将',
  '组',
  '见',
  '计',
  '别',
  '她',
  '手',
  '角',
  '期',
  '根',
  '论',
  '运',
  '农',
  '指',
  '几',
  '九',
  '区',
  '强',
  '放',
  '决',
  '西',
  '被',
  '干',
  '做',
  '必',
  '战',
  '先',
  '回',
  '则',
  '任',
  '取',
  '据',
  '处',
  '队',
  '南',
  '给',
  '色',
  '光',
  '门',
  '即',
  '保',
  '治',
  '北',
  '造',
  '百',
  '规',
  '热',
  '领',
  '七',
  '海',
  '口',
  '东',
  '导',
  '器',
  '压',
  '志',
  '世',
  '金',
  '增',
  '争',
  '济',
  '阶',
  '油',
  '思',
  '术',
  '极',
  '交',
  '受',
  '联',
  '什',
  '认',
  '六',
  '共',
  '权',
  '收',
  '证',
  '改',
  '清',
  '美',
  '再',
  '采',
  '转',
  '更',
  '单',
  '风',
  '切',
  '打',
  '白',
  '教',
  '速',
  '花',
  '带',
  '安',
  '场',
  '身',
  '车',
  '例',
  '真',
  '务',
  '具',
  '万',
  '每',
  '目',
  '至',
  '达',
  '走',
  '积',
  '示',
  '议',
  '声',
  '报',
  '斗',
  '完',
  '类',
  '八',
  '离',
  '华',
  '名',
  '确',
  '才',
  '科',
  '张',
  '信',
  '马',
  '节',
  '话',
  '米',
  '整',
  '空',
  '元',
  '况',
  '今',
  '集',
  '温',
  '传',
  '土',
  '许',
  '步',
  '群',
  '广',
  '石',
  '记',
  '需',
  '段',
  '研',
  '界',
  '拉',
  '林',
  '律',
  '叫',
  '且',
  '究',
  '观',
  '越',
  '织',
  '装',
  '影',
  '算',
  '低',
  '持',
  '音',
  '众',
  '书',
  '布',
  '复',
  '容',
  '儿',
  '须',
  '际',
  '商',
  '非',
  '验',
  '连',
  '断',
  '深',
  '难',
  '近',
  '矿',
  '千',
  '周',
  '委',
  '素',
  '技',
  '备',
  '半',
  '办',
  '青',
  '省',
  '列',
  '习',
  '响',
  '约',
  '支',
  '般',
  '史',
  '感',
  '劳',
  '便',
  '团',
  '往',
  '酸',
  '历',
  '市',
  '克',
  '何',
  '除',
  '消',
  '构',
  '府',
  '称',
  '太',
  '准',
  '精',
  '值',
  '号',
  '率',
  '族',
  '维',
  '划',
  '选',
  '标',
  '写',
  '存',
  '候',
  '毛',
  '亲',
  '快',
  '效',
  '斯',
  '院',
  '查',
  '江',
  '型',
  '眼',
  '王',
  '按',
  '格',
  '养',
  '易',
  '置',
  '派',
  '层',
  '片',
  '始',
  '却',
  '专',
  '状',
  '育',
  '厂',
  '京',
  '识',
  '适',
  '属',
  '圆',
  '包',
  '火',
  '住',
  '调',
  '满',
  '县',
  '局',
  '照',
  '参',
  '红',
  '细',
  '引',
  '听',
  '该',
  '铁',
  '价',
  '严',
  '首',
  '底',
  '液',
  '官',
  '德',
  '随',
  '病',
  '苏',
  '失',
  '尔',
  '死',
  '讲',
  '配',
  '女',
  '黄',
  '推',
  '显',
  '谈',
  '罪',
  '神',
  '艺',
  '呢',
  '席',
  '含',
  '企',
  '望',
  '密',
  '批',
  '营',
  '项',
  '防',
  '举',
  '球',
  '英',
  '氧',
  '势',
  '告',
  '李',
  '台',
  '落',
  '木',
  '帮',
  '轮',
  '破',
  '亚',
  '师',
  '围',
  '注',
  '远',
  '字',
  '材',
  '排',
  '供',
  '河',
  '态',
  '封',
  '另',
  '施',
  '减',
  '树',
  '溶',
  '怎',
  '止',
  '案',
  '言',
  '士',
  '均',
  '武',
  '固',
  '叶',
  '鱼',
  '波',
  '视',
  '仅',
  '费',
  '紧',
  '爱',
  '左',
  '章',
  '早',
  '朝',
  '害',
  '续',
  '轻',
  '服',
  '试',
  '食',
  '充',
  '兵',
  '源',
  '判',
  '护',
  '司',
  '足',
  '某',
  '练',
  '差',
  '致',
  '板',
  '田',
  '降',
  '黑',
  '犯',
  '负',
  '击',
  '范',
  '继',
  '兴',
  '似',
  '余',
  '坚',
  '曲',
  '输',
  '修',
  '故',
  '城',
  '夫',
  '够',
  '送',
  '笔',
  '船',
  '占',
  '右',
  '财',
  '吃',
  '富',
  '春',
  '职',
  '觉',
  '汉',
  '画',
  '功',
  '巴',
  '跟',
  '虽',
  '杂',
  '飞',
  '检',
  '吸',
  '助',
  '升',
  '阳',
  '互',
  '初',
  '创',
  '抗',
  '考',
  '投',
  '坏',
  '策',
  '古',
  '径',
  '换',
  '未',
  '跑',
  '留',
  '钢',
  '曾',
  '端',
  '责',
  '站',
  '简',
  '述',
  '钱',
  '副',
  '尽',
  '帝',
  '射',
  '草',
  '冲',
  '承',
  '独',
  '令',
  '限',
  '阿',
  '宣',
  '环',
  '双',
  '请',
  '超',
  '微',
  '让',
  '控',
  '州',
  '良',
  '轴',
  '找',
  '否',
  '纪',
  '益',
  '依',
  '优',
  '顶',
  '础',
  '载',
  '倒',
  '房',
  '突',
  '坐',
  '粉',
  '敌',
  '略',
  '客',
  '袁',
  '冷',
  '胜',
  '绝',
  '析',
  '块',
  '剂',
  '测',
  '丝',
  '协',
  '诉',
  '念',
  '陈',
  '仍',
  '罗',
  '盐',
  '友',
  '洋',
  '错',
  '苦',
  '夜',
  '刑',
  '移',
  '频',
  '逐',
  '靠',
  '混',
  '母',
  '短',
  '皮',
  '终',
  '聚',
  '汽',
  '村',
  '云',
  '哪',
  '既',
  '距',
  '卫',
  '停',
  '烈',
  '央',
  '察',
  '烧',
  '迅',
  '境',
  '若',
  '印',
  '洲',
  '刻',
  '括',
  '激',
  '孔',
  '搞',
  '甚',
  '室',
  '待',
  '核',
  '校',
  '散',
  '侵',
  '吧',
  '甲',
  '游',
  '久',
  '菜',
  '味',
  '旧',
  '模',
  '湖',
  '货',
  '损',
  '预',
  '阻',
  '毫',
  '普',
  '稳',
  '乙',
  '妈',
  '植',
  '息',
  '扩',
  '银',
  '语',
  '挥',
  '酒',
  '守',
  '拿',
  '序',
  '纸',
  '医',
  '缺',
  '雨',
  '吗',
  '针',
  '刘',
  '啊',
  '急',
  '唱',
  '误',
  '训',
  '愿',
  '审',
  '附',
  '获',
  '茶',
  '鲜',
  '粮',
  '斤',
  '孩',
  '脱',
  '硫',
  '肥',
  '善',
  '龙',
  '演',
  '父',
  '渐',
  '血',
  '欢',
  '械',
  '掌',
  '歌',
  '沙',
  '刚',
  '攻',
  '谓',
  '盾',
  '讨',
  '晚',
  '粒',
  '乱',
  '燃',
  '矛',
  '乎',
  '杀',
  '药',
  '宁',
  '鲁',
  '贵',
  '钟',
  '煤',
  '读',
  '班',
  '伯',
  '香',
  '介',
  '迫',
  '句',
  '丰',
  '培',
  '握',
  '兰',
  '担',
  '弦',
  '蛋',
  '沉',
  '假',
  '穿',
  '执',
  '答',
  '乐',
  '谁',
  '顺',
  '烟',
  '缩',
  '征',
  '脸',
  '喜',
  '松',
  '脚',
  '困',
  '异',
  '免',
  '背',
  '星',
  '福',
  '买',
  '染',
  '井',
  '概',
  '慢',
  '怕',
  '磁',
  '倍',
  '祖',
  '皇',
  '促',
  '静',
  '补',
  '评',
  '翻',
  '肉',
  '践',
  '尼',
  '衣',
  '宽',
  '扬',
  '棉',
  '希',
  '伤',
  '操',
  '垂',
  '秋',
  '宜',
  '氢',
  '套',
  '督',
  '振',
  '架',
  '亮',
  '末',
  '宪',
  '庆',
  '编',
  '牛',
  '触',
  '映',
  '雷',
  '销',
  '诗',
  '座',
  '居',
  '抓',
  '裂',
  '胞',
  '呼',
  '娘',
  '景',
  '威',
  '绿',
  '晶',
  '厚',
  '盟',
  '衡',
  '鸡',
  '孙',
  '延',
  '危',
  '胶',
  '屋',
  '乡',
  '临',
  '陆',
  '顾',
  '掉',
  '呀',
  '灯',
  '岁',
  '措',
  '束',
  '耐',
  '剧',
  '玉',
  '赵',
  '跳',
  '哥',
  '季',
  '课',
  '凯',
  '胡',
  '额',
  '款',
  '绍',
  '卷',
  '齐',
  '伟',
  '蒸',
  '殖',
  '永',
  '宗',
  '苗',
  '川',
  '炉',
  '岩',
  '弱',
  '零',
  '杨',
  '奏',
  '沿',
  '露',
  '杆',
  '探',
  '滑',
  '镇',
  '饭',
  '浓',
  '航',
  '怀',
  '赶',
  '库',
  '夺',
  '伊',
  '灵',
  '税',
  '途',
  '灭',
  '赛',
  '归',
  '召',
  '鼓',
  '播',
  '盘',
  '裁',
  '险',
  '康',
  '唯',
  '录',
  '菌',
  '纯',
  '借',
  '糖',
  '盖',
  '横',
  '符',
  '私',
  '努',
  '堂',
  '域',
  '枪',
  '润',
  '幅',
  '哈',
  '竟',
  '熟',
  '虫',
  '泽',
  '脑',
  '壤',
  '碳',
  '欧',
  '遍',
  '侧',
  '寨',
  '敢',
  '彻',
  '虑',
  '斜',
  '薄',
  '庭',
  '纳',
  '弹',
  '饲',
  '伸',
  '折',
  '麦',
  '湿',
  '暗',
  '荷',
  '瓦',
  '塞',
  '床',
  '筑',
  '恶',
  '户',
  '访',
  '塔',
  '奇',
  '透',
  '梁',
  '刀',
  '旋',
  '迹',
  '卡',
  '氯',
  '遇',
  '份',
  '毒',
  '泥',
  '退',
  '洗',
  '摆',
  '灰',
  '彩',
  '卖',
  '耗',
  '夏',
  '择',
  '忙',
  '铜',
  '献',
  '硬',
  '予',
  '繁',
  '圈',
  '雪',
  '函',
  '亦',
  '抽',
  '篇',
  '阵',
  '阴',
  '丁',
  '尺',
  '追',
  '堆',
  '雄',
  '迎',
  '泛',
  '爸',
  '楼',
  '避',
  '谋',
  '吨',
  '野',
  '猪',
  '旗',
  '累',
  '偏',
  '典',
  '馆',
  '索',
  '秦',
  '脂',
  '潮',
  '爷',
  '豆',
  '忽',
  '托',
  '惊',
  '塑',
  '遗',
  '愈',
  '朱',
  '替',
  '纤',
  '粗',
  '倾',
  '尚',
  '痛',
  '楚',
  '谢',
  '奋',
  '购',
  '磨',
  '君',
  '池',
  '旁',
  '碎',
  '骨',
  '监',
  '捕',
  '弟',
  '暴',
  '割',
  '贯',
  '殊',
  '释',
  '词',
  '亡',
  '壁',
  '顿',
  '宝',
  '午',
  '尘',
  '闻',
  '揭',
  '炮',
  '残',
  '冬',
  '桥',
  '妇',
  '警',
  '综',
  '招',
  '吴',
  '付',
  '浮',
  '遭',
  '徐',
  '您',
  '摇',
  '谷',
  '赞',
  '箱',
  '隔',
  '订',
  '男',
  '吹',
  '园',
  '纷',
  '唐',
  '败',
  '宋',
  '玻',
  '巨',
  '耕',
  '坦',
  '荣',
  '闭',
  '湾',
  '键',
  '凡',
  '驻',
  '锅',
  '救',
  '恩',
  '剥',
  '凝',
  '碱',
  '齿',
  '截',
  '炼',
  '麻',
  '纺',
  '禁',
  '废',
  '盛',
  '版',
  '缓',
  '净',
  '睛',
  '昌',
  '婚',
  '涉',
  '筒',
  '嘴',
  '插',
  '岸',
  '朗',
  '庄',
  '街',
  '藏',
  '姑',
  '贸',
  '腐',
  '奴',
  '啦',
  '惯',
  '乘',
  '伙',
  '恢',
  '匀',
  '纱',
  '扎',
  '辩',
  '耳',
  '彪',
  '臣',
  '亿',
  '璃',
  '抵',
  '脉',
  '秀',
  '萨',
  '俄',
  '网',
  '舞',
  '店',
  '喷',
  '纵',
  '寸',
  '汗',
  '挂',
  '洪',
  '贺',
  '闪',
  '柬',
  '爆',
  '烯',
  '津',
  '稻',
  '墙',
  '软',
  '勇',
  '像',
  '滚',
  '厘',
  '蒙',
  '芳',
  '肯',
  '坡',
  '柱',
  '荡',
  '腿',
  '仪',
  '旅',
  '尾',
  '轧',
  '冰',
  '贡',
  '登',
  '黎',
  '削',
  '钻',
  '勒',
  '逃',
  '障',
  '氨',
  '郭',
  '峰',
  '币',
  '港',
  '伏',
  '轨',
  '亩',
  '毕',
  '擦',
  '莫',
  '刺',
  '浪',
  '秘',
  '援',
  '株',
  '健',
  '售',
  '股',
  '岛',
  '甘',
  '泡',
  '睡',
  '童',
  '铸',
  '汤',
  '阀',
  '休',
  '汇',
  '舍',
  '牧',
  '绕',
  '炸',
  '哲',
  '磷',
  '绩',
  '朋',
  '淡',
  '尖',
  '启',
  '陷',
  '柴',
  '呈',
  '徒',
  '颜',
  '泪',
  '稍',
  '忘',
  '泵',
  '蓝',
  '拖',
  '洞',
  '授',
  '镜',
  '辛',
  '壮',
  '锋',
  '贫',
  '虚',
  '弯',
  '摩',
  '泰',
  '幼',
  '廷',
  '尊',
  '窗',
  '纲',
  '弄',
  '隶',
  '疑',
  '氏',
  '宫',
  '姐',
  '震',
  '瑞',
  '怪',
  '尤',
  '琴',
  '循',
  '描',
  '膜',
  '违',
  '夹',
  '腰',
  '缘',
  '珠',
  '穷',
  '森',
  '枝',
  '竹',
  '沟',
  '催',
  '绳',
  '忆',
  '邦',
  '剩',
  '幸',
  '浆',
  '栏',
  '拥',
  '牙',
  '贮',
  '礼',
  '滤',
  '钠',
  '纹',
  '罢',
  '拍',
  '咱',
  '喊',
  '袖',
  '埃',
  '勤',
  '罚',
  '焦',
  '潜',
  '伍',
  '墨',
  '欲',
  '缝',
  '姓',
  '刊',
  '饱',
  '仿',
  '奖',
  '铝',
  '鬼',
  '丽',
  '跨',
  '默',
  '挖',
  '链',
  '扫',
  '喝',
  '袋',
  '炭',
  '污',
  '幕',
  '诸',
  '弧',
  '励',
  '梅',
  '奶',
  '洁',
  '灾',
  '舟',
  '鉴',
  '苯',
  '讼',
  '抱',
  '毁',
  '懂',
  '寒',
  '智',
  '埔',
  '寄',
  '届',
  '跃',
  '渡',
  '挑',
  '丹',
  '艰',
  '贝',
  '碰',
  '拔',
  '爹',
  '戴',
  '码',
  '梦',
  '芽',
  '熔',
  '赤',
  '渔',
  '哭',
  '敬',
  '颗',
  '奔',
  '铅',
  '仲',
  '虎',
  '稀',
  '妹',
  '乏',
  '珍',
  '申',
  '桌',
  '遵',
  '允',
  '隆',
  '螺',
  '仓',
  '魏',
  '锐',
  '晓',
  '氮',
  '兼',
  '隐',
  '碍',
  '赫',
  '拨',
  '忠',
  '肃',
  '缸',
  '牵',
  '抢',
  '博',
  '巧',
  '壳',
  '兄',
  '杜',
  '讯',
  '诚',
  '碧',
  '祥',
  '柯',
  '页',
  '巡',
  '矩',
  '悲',
  '灌',
  '龄',
  '伦',
  '票',
  '寻',
  '桂',
  '铺',
  '圣',
  '恐',
  '恰',
  '郑',
  '趣',
  '抬',
  '荒',
  '腾',
  '贴',
  '柔',
  '滴',
  '猛',
  '阔',
  '辆',
  '妻',
  '填',
  '撤',
  '储',
  '签',
  '闹',
  '扰',
  '紫',
  '砂',
  '递',
  '戏',
  '吊',
  '陶',
  '伐',
  '喂',
  '疗',
  '瓶',
  '婆',
  '抚',
  '臂',
  '摸',
  '忍',
  '虾',
  '蜡',
  '邻',
  '胸',
  '巩',
  '挤',
  '偶',
  '弃',
  '槽',
  '劲',
  '乳',
  '邓',
  '吉',
  '仁',
  '烂',
  '砖',
  '租',
  '乌',
  '舰',
  '伴',
  '瓜',
  '浅',
  '丙',
  '暂',
  '燥',
  '橡',
  '柳',
  '迷',
  '暖',
  '牌',
  '秧',
  '胆',
  '详',
  '簧',
  '踏',
  '瓷',
  '谱',
  '呆',
  '宾',
  '糊',
  '洛',
  '辉',
  '愤',
  '竞',
  '隙',
  '怒',
  '粘',
  '乃',
  '绪',
  '肩',
  '籍',
  '敏',
  '涂',
  '熙',
  '皆',
  '侦',
  '悬',
  '掘',
  '享',
  '纠',
  '醒',
  '狂',
  '锁',
  '淀',
  '恨',
  '牲',
  '霸',
  '爬',
  '赏',
  '逆',
  '玩',
  '陵',
  '祝',
  '秒',
  '浙',
  '貌',
  '役',
  '彼',
  '悉',
  '鸭',
  '趋',
  '凤',
  '晨',
  '畜',
  '辈',
  '秩',
  '卵',
  '署',
  '梯',
  '炎',
  '滩',
  '棋',
  '驱',
  '筛',
  '峡',
  '冒',
  '啥',
  '寿',
  '译',
  '浸',
  '泉',
  '帽',
  '迟',
  '硅',
  '疆',
  '贷',
  '漏',
  '稿',
  '冠',
  '嫩',
  '胁',
  '芯',
  '牢',
  '叛',
  '蚀',
  '奥',
  '鸣',
  '岭',
  '羊',
  '凭',
  '串',
  '塘',
  '绘',
  '酵',
  '融',
  '盆',
  '锡',
  '庙',
  '筹',
  '冻',
  '辅',
  '摄',
  '袭',
  '筋',
  '拒',
  '僚',
  '旱',
  '钾',
  '鸟',
  '漆',
  '沈',
  '眉',
  '疏',
  '添',
  '棒',
  '穗',
  '硝',
  '韩',
  '逼',
  '扭',
  '侨',
  '凉',
  '挺',
  '碗',
  '栽',
  '炒',
  '杯',
  '患',
  '馏',
  '劝',
  '豪',
  '辽',
  '勃',
  '鸿',
  '旦',
  '吏',
  '拜',
  '狗',
  '埋',
  '辊',
  '掩',
  '饮',
  '搬',
  '骂',
  '辞',
  '勾',
  '扣',
  '估',
  '蒋',
  '绒',
  '雾',
  '丈',
  '朵',
  '姆',
  '拟',
  '宇',
  '辑',
  '陕',
  '雕',
  '偿',
  '蓄',
  '崇',
  '剪',
  '倡',
  '厅',
  '咬',
  '驶',
  '薯',
  '刷',
  '斥',
  '番',
  '赋',
  '奉',
  '佛',
  '浇',
  '漫',
  '曼',
  '扇',
  '钙',
  '桃',
  '扶',
  '仔',
  '返',
  '俗',
  '亏',
  '腔',
  '鞋',
  '棱',
  '覆',
  '框',
  '悄',
  '叔',
  '撞',
  '骗',
  '勘',
  '旺',
  '沸',
  '孤',
  '吐',
  '孟',
  '渠',
  '屈',
  '疾',
  '妙',
  '惜',
  '仰',
  '狠',
  '胀',
  '谐',
  '抛',
  '霉',
  '桑',
  '岗',
  '嘛',
  '衰',
  '盗',
  '渗',
  '脏',
  '赖',
  '涌',
  '甜',
  '曹',
  '阅',
  '肌',
  '哩',
  '厉',
  '烃',
  '纬',
  '毅',
  '昨',
  '伪',
  '症',
  '煮',
  '叹',
  '钉',
  '搭',
  '茎',
  '笼',
  '酷',
  '偷',
  '弓',
  '锥',
  '恒',
  '杰',
  '坑',
  '鼻',
  '翼',
  '纶',
  '叙',
  '狱',
  '逮',
  '罐',
  '络',
  '棚',
  '抑',
  '膨',
  '蔬',
  '寺',
  '骤',
  '穆',
  '冶',
  '枯',
  '册',
  '尸',
  '凸',
  '绅',
  '坯',
  '牺',
  '焰',
  '轰',
  '欣',
  '晋',
  '瘦',
  '御',
  '锭',
  '锦',
  '丧',
  '旬',
  '锻',
  '垄',
  '搜',
  '扑',
  '邀',
  '亭',
  '酯',
  '迈',
  '舒',
  '脆',
  '酶',
  '闲',
  '忧',
  '酚',
  '顽',
  '羽',
  '涨',
  '卸',
  '仗',
  '陪',
  '辟',
  '惩',
  '杭',
  '姚',
  '肚',
  '捉',
  '飘',
  '漂',
  '昆',
  '欺',
  '吾',
  '郎',
  '烷',
  '汁',
  '呵',
  '饰',
  '萧',
  '雅',
  '邮',
  '迁',
  '燕',
  '撒',
  '姻',
  '赴',
  '宴',
  '烦',
  '债',
  '帐',
  '斑',
  '铃',
  '旨',
  '醇',
  '董',
  '饼',
  '雏',
  '姿',
  '拌',
  '傅',
  '腹',
  '妥',
  '揉',
  '贤',
  '拆',
  '歪',
  '葡',
  '胺',
  '丢',
  '浩',
  '徽',
  '昂',
  '垫',
  '挡',
  '览',
  '贪',
  '慰',
  '缴',
  '汪',
  '慌',
  '冯',
  '诺',
  '姜',
  '谊',
  '凶',
  '劣',
  '诬',
  '耀',
  '昏',
  '躺',
  '盈',
  '骑',
  '乔',
  '溪',
  '丛',
  '卢',
  '抹',
  '闷',
  '咨',
  '刮',
  '驾',
  '缆',
  '悟',
  '摘',
  '铒',
  '掷',
  '颇',
  '幻',
  '柄',
  '惠',
  '惨',
  '佳',
  '仇',
  '腊',
  '窝',
  '涤',
  '剑',
  '瞧',
  '堡',
  '泼',
  '葱',
  '罩',
  '霍',
  '捞',
  '胎',
  '苍',
  '滨',
  '俩',
  '捅',
  '湘',
  '砍',
  '霞',
  '邵',
  '萄',
  '疯',
  '淮',
  '遂',
  '熊',
  '粪',
  '烘',
  '宿',
  '档',
  '戈',
  '驳',
  '嫂',
  '裕',
  '徙',
  '箭',
  '捐',
  '肠',
  '撑',
  '晒',
  '辨',
  '殿',
  '莲',
  '摊',
  '搅',
  '酱',
  '屏',
  '疫',
  '哀',
  '蔡',
  '堵',
  '沫',
  '皱',
  '畅',
  '叠',
  '阁',
  '莱',
  '敲',
  '辖',
  '钩',
  '痕',
  '坝',
  '巷',
  '饿',
  '祸',
  '丘',
  '玄',
  '溜',
  '曰',
  '逻',
  '彭',
  '尝',
  '卿',
  '妨',
  '艇',
  '吞',
  '韦',
  '怨',
  '矮',
  '歇'
);
killList:array[0..882] of ansistring=( //Расстрельный список паролей
 'fktrcfylh',
 'fyfcnfcbz',
 'qazwsx',
 'ghbdtn',
 'knopka',
 'gfhjkm',
 'vfhbyf',
 'yfnfif',
 'vfrcbv',
 'k.,jdm',
 'fylhtq',
 'spartak',
 'easytocrack',
 'parola',
 'hallo',
 'ngockhoa',
 'hejsan',


'1111',
'1212',
'1234',
'1988',
'1989',
'1990',
'1991',
'1992',
'1993',
'2000',
'2112',
'2222',
'4321',
'4444',
'5150',
'6969',
'7007',
'7777',
'11111',
'12345',
'54321',
'55555',
'101010',
'102030',
'111111',
'111222',
'112233',
'121212',
'123123',
'123321',
'123456',
'123654',
'123789',
'131313',
'159357',
'159753',
'212121',
'222222',
'232323',
'252525',
'315475',
'333333',
'444444',
'555555',
'654321',
'666666',
'696969',
'777777',
'789456',
'888888',
'987654',
'999999',
'1012011',
'1111111',
'1234567',
'7654321',
'7777777',
'8675309',
'11111111',
'11223344',
'12341234',
'12344321',
'12345678',
'69696969',
'87654321',
'88888888',
'123123123',
'123456789',
'789456123',
'987654321',
'1234554321',
'1234567890',
'4815162342',
'123456789a',
'123456a',
'123456q',
'12345a',
'12345q',
'12345z',
'1234qwe',
'1234qwe',
'1234qwer',
'123abc',
'123qwe',
'123qwe',
'12qwaszx',
'18atcskd2w',
'1C',
'1q2w3e',
'1q2w3e4r',
'1q2w3e4r5t',
'1q2w3e4r5t',
'1qaz2wsx',
'1qazxsw2',
'3rjs1la7qe',
'aaa',
'aaaaaa',
'abc123',
'abcd1234',
'abcdef',
'access',
'accounting',
'acer',
'adelina',
'adidas',
'adm',
'admin',
'administrator',
'agata',
'agniia',
'agniya',
'aida',
'airborne',
'aksinia',
'aksinya',
'alan',
'albert',
'albina',
'aleksander',
'aleksandr',
'aleksandra',
'aleksei',
'alena',
'alex',
'alexander',
'alexey',
'alexis',
'aliia',
'alina',
'alisa',
'aliya',
'alla',
'amanda',
'ameliia',
'ameliya',
'america',
'amina',
'anastasiia',
'anastasiya',
'anatolii',
'anatoly',
'andrea',
'andrei',
'andrew',
'angel',
'angela',
'angelina',
'angels',
'animal',
'anna',
'anthony',
'anton',
'antonina',
'apollo',
'apple',
'apples',
'ariana',
'arina',
'arsen',
'arsenal',
'arsenii',
'arseny',
'artem',
'artemii',
'artemy',
'arthur',
'artur',
'asdasd',
'asdf',
'asdfasdf',
'asdfgh',
'asdfghjk',
'asdfghjkl',
'ashley',
'asshole',
'audit',
'august',
'austin',
'azerty',
'backup',
'badboy',
'bailey',
'banana',
'bandit',
'barney',
'baseball',
'batman',
'bear',
'beaver',
'beavis',
'benjamin',
'bigdaddy',
'bigdick',
'bigdog',
'bigtits',
'bitch',
'biteme',
'black',
'blazer',
'blink182',
'blowjob',
'blowme',
'blue',
'bogdan',
'bond007',
'bonnie',
'booboo',
'booger',
'boomer',
'boris',
'boston',
'brandon',
'brandy',
'braves',
'brooklyn',
'bubba',
'buddy',
'buh',
'bukh',
'bulldog',
'bullshit',
'buster',
'butter',
'butthead',
'calvin',
'camaro',
'cameron',
'canada',
'captain',
'carlos',
'casper',
'changeme',
'charles',
'charlie',
'cheese',
'chelsea',
'chester',
'chicago',
'chicken',
'chris',
'cisco',
'cocacola',
'coffee',
'compaq',
'computer',
'consult',
'cookie',
'cooper',
'copper',
'corvette',
'cowboy',
'cowboys',
'creative',
'cricket',
'crystal',
'dakota',
'dallas',
'damir',
'daniel',
'danielle',
'daniil',
'daria',
'darina',
'darkness',
'darya',
'david',
'debbie',
'december',
'default',
'dell',
'demian',
'demid',
'demo',
'denis',
'dennis',
'dexter',
'diablo',
'diamond',
'diana',
'dick',
'dina',
'dmitrii',
'dmitry',
'doctor',
'dolphin',
'dolphins',
'donkey',
'dragon',
'driver',
'eagles',
'eduard',
'edward',
'egor',
'ekaterina',
'eldar',
'elena',
'elephant',
'elina',
'elisei',
'elizaveta',
'elmira',
'elvira',
'emil',
'emiliia',
'emiliya',
'eminem',
'enter',
'erik',
'eseniia',
'eseniya',
'eva',
'evangelina',
'evelina',
'evgeniia',
'evgeniya',
'evgeny',
'falcon',
'fedor',
'fender',
'ferrari',
'filip',
'filipp',
'fish',
'fishing',
'florida',
'flower',
'football',
'forever',
'fred',
'freddy',
'freedom',
'fuck',
'fucker',
'fucking',
'fuckme',
'fuckoff',
'fuckyou',
'galina',
'gandalf',
'garfield',
'gateway',
'gators',
'gemini',
'gennadii',
'gennady',
'george',
'georgii',
'georgy',
'german',
'gfhjkm',
'ghbdtn',
'giants',
'ginger',
'girls',
'gleb',
'godzilla',
'golden',
'golf',
'golfer',
'google',
'gordei',
'gordon',
'green',
'grigorii',
'grigory',
'guest',
'guitar',
'gunner',
'hammer',
'hannah',
'happy',
'hardcore',
'harley',
'heather',
'heaven',
'hello',
'helpme',
'hockey',
'hooters',
'horny',
'hotdog',
'hunter',
'ian',
'iana',
'iaroslav',
'iaroslava',
'ibm',
'iceman',
'ignat',
'igor',
'ilia',
'ilias',
'ilona',
'iloveyou',
'ilya',
'ilyas',
'inna',
'intel',
'internet',
'irina',
'iulia',
'iuliia',
'iulya',
'iurii',
'ivan',
'iwantu',
'jack',
'jackass',
'jackie',
'jackson',
'jaguar',
'james',
'jasmine',
'jason',
'jasper',
'jennifer',
'jeremy',
'jessica',
'jessie',
'john',
'johnny',
'johnson',
'jonathan',
'jordan',
'jordan23',
'joseph',
'joshua',
'julia',
'julya',
'junior',
'justin',
'kamil',
'kamilla',
'karim',
'karina',
'karolina',
'killer',
'kira',
'kirill',
'kitten',
'klaster',
'klavdiia',
'klavdiya',
'klim',
'knight',
'konstantin',
'kristina',
'kseniia',
'kseniya',
'lakers',
'lana',
'larisa',
'lauren',
'legend',
'leila',
'leonid',
'letmein',
'lev',
'liana',
'lidiia',
'lidiya',
'lifehack',
'liia',
'liliia',
'liliya',
'lina',
'liubov',
'liuda',
'liudmila',
'liverpoo',
'liverpool',
'liya',
'ljubov',
'login',
'london',
'love',
'loveme',
'lover',
'lovers',
'lubov',
'lucky',
'luda',
'ludmila',
'maddog',
'madison',
'maggie',
'magic',
'maiia',
'mail',
'maint',
'maiya',
'makar',
'maksim',
'manager',
'marat',
'margarita',
'marianna',
'mariia',
'marina',
'marine',
'mariya',
'mark',
'marketing',
'marlboro',
'marsel',
'martin',
'master',
'matrix',
'matthew',
'matvei',
'maverick',
'maxim',
'maxwell',
'melaniia',
'melaniya',
'melissa',
'mercedes',
'merlin',
'metallic',
'michael',
'michelle',
'mickey',
'midnight',
'mike',
'mikhail',
'mila',
'milana',
'milena',
'miller',
'miron',
'miroslav',
'miroslava',
'money',
'monica',
'monkey',
'monster',
'morgan',
'mother',
'mountain',
'muffin',
'murphy',
'mustang',
'mynoob',
'nadezhda',
'nascar',
'nastja',
'natalia',
'nataly',
'natalya',
'natasha',
'nathan',
'nazar',
'ncc1701',
'nelli',
'newyork',
'nicholas',
'nicole',
'nika',
'nikita',
'nikolai',
'nikolay',
'nina',
'nirvana',
'nissan',
'nothing',
'oksana',
'oleg',
'olesia',
'olesya',
'olga',
'oliver',
'olya',
'online',
'operator',
'orange',
'packers',
'pakistan',
'panther',
'panties',
'parker',
'pass',
'passw0rd',
'password',
'password0',
'password1',
'password2',
'password3',
'password4',
'password5',
'password6',
'password7',
'password8',
'password9',
'patrick',
'pavel',
'peaches',
'peanut',
'pepper',
'petr',
'phantom',
'philip',
'philipp',
'phoenix',
'platinum',
'platon',
'playboy',
'player',
'please',
'pokemon',
'police',
'polina',
'pookie',
'porn',
'porsche',
'power',
'prince',
'princess',
'private',
'production',
'prohor',
'prokhor',
'purple',
'pussy',
'q1w2e3',
'q1w2e3r4',
'q1w2e3r4t5',
'qazwsx',
'qazwsxedc',
'qazxsw',
'qqqqq',
'qqqqqq',
'qwaszx',
'qwe123',
'qweasdzxc',
'qweqwe',
'qwer1234',
'qwert',
'qwerty',
'qwerty123',
'qwertyu',
'qwertyui',
'qwertyuiop',
'rabbit',
'rachel',
'raiders',
'rainbow',
'ramil',
'ranger',
'rangers',
'ratmir',
'razz',
'rebecca',
'red123',
'redskins',
'redsox',
'redwings',
'regina',
'remote',
'renat',
'richard',
'rinat',
'robert',
'rocket',
'rodion',
'roman',
'root',
'rootroot',
'rosebud',
'rostislav',
'rush2112',
'ruslan',
'rustam',
'sabina',
'sales',
'samantha',
'samson',
'samsung',
'sandra',
'saturn',
'savelii',
'savely',
'savva',
'scooby',
'scooter',
'scorpio',
'scorpion',
'secret',
'security',
'semen',
'sergei',
'sergey',
'service',
'sexsex',
'sexy',
'shadow',
'shamil',
'shannon',
'share',
'shelby',
'shithead',
'sierra',
'silver',
'skippy',
'slayer',
'slipknot',
'smokey',
'sniper',
'snoopy',
'snowball',
'soccer',
'sofia',
'sofiia',
'sofiya',
'sofy',
'sofya',
'sophie',
'spanky',
'sparky',
'specialist',
'spider',
'stanislav',
'startrek',
'starwars',
'steelers',
'stefaniia',
'stefaniya',
'stefany',
'stella',
'stepan',
'steven',
'student',
'stupid',
'success',
'suckit',
'summer',
'sunshine',
'superman',
'superuser',
'supervisor',
'support',
'sveta',
'svetik',
'svetlana',
'sviatoslav',
'svyatoslav',
'switch',
'sydney',
'sysadm',
'system',
'taisiia',
'taisiya',
'tamara',
'tamerlan',
'tatiana',
'tatyana',
'taylor',
'teacher',
'temp',
'temp123',
'temporary',
'temptemp',
'tennis',
'test',
'test123',
'testtest',
'theman',
'therock',
'thomas',
'thunder',
'thx1138',
'tiffany',
'tiger',
'tigers',
'tigger',
'tihon',
'tikhon',
'timofei',
'timofey',
'timur',
'tomcat',
'toyota',
'travis',
'trouble',
'trustno1',
'tucker',
'turtle',
'tutor',
'uliana',
'ulyana',
'united',
'user0',
'user1',
'user2',
'user3',
'user4',
'user5',
'user6',
'user7',
'user8',
'user9',
'vadim',
'valentin',
'valentina',
'valerii',
'valeriia',
'valeriya',
'varvara',
'vasilii',
'vasilina',
'vasilisa',
'vasily',
'vera',
'veronika',
'viacheslav',
'victor',
'victoria',
'viking',
'viktor',
'viktoriia',
'viktoriya',
'violetta',
'vitalii',
'vitaly',
'vladimir',
'vladislav',
'vladislava',
'voodoo',
'voyager',
'vsevolod',
'walter',
'warrior',
'welcome',
'whatever',
'william',
'willie',
'willow',
'wilson',
'windows',
'winner',
'winston',
'winter',
'wizard',
'work123',
'xavier',
'xxxxx',
'xxxxxx',
'xxxxxxxx',
'yamaha',
'yan',
'yankees',
'yaroslav',
'yellow',
'yri',
'zakhar',
'zarina',
'zhanna',
'zhenia',
'zhenya',
'zlata',
'zxccxz',
'zxcvb',
'zxcvbn',
'zxcvbnm',
'zxcxz',
'zzzzz',
'zzzzzz'
);

type
  arrayOfstring=array of string;

//function ratePasswordUnicode(password:string):double; //log10 rate
function ratePassword(password:string):double; //log10 rate

function SymbolCount(s:string):integer;

function makeBIP39RandomPassword(d:double;const bipArray:array of string;divider:string=' '):ansistring; //log10 rate
function makeCharRandomPassword(d:double;charstring:ansistring):ansistring; //log10 rate

//random generator

type
 tRndGen=class(tObject)
   private
     frnSeed:dWord;
     frndCallCount:integer;
     function isReady:boolean;
   public
     property rndReady:boolean read isReady;
     constructor create(); overload;
     procedure doRandomize(x:dWord);
     function getRandom(n:dWord):dWord;
 end;

var
  lastRatePasswordBonuses:tStringList;
  lastRatePasswordPenalties:tStringList;
  RndGen:tRndGen;

function bip39tobytes(bip:string):ansistring; overload;
function bip39tobytes(bip:string;const bipArray:array of string;divider:string=''):ansistring;
function decodePassword(pwd:string;decodeBIP39Asbits:boolean=true):ansistring;

function UTF8toAnsiCharArray(S: String):arrayOfString;
function splitString(s,divider: String;ignoreEmpty:boolean=true):arrayOfString;


function createBinaryBIP32seed(recovery:ansistring;pbipArray:pointer=nil;pass:ansistring='witnesskey'):ansistring; //64 bytes
function createBIP32seed(recovery:string;pass:string='witnesskey';iterCount:integer=2048):ansistring; //64 bytes

function normalizeBip(bip:string):string;

function getBip39FromMasterPassword(buf:ansistring):string;
function smartExtractBIP32pass(pass:string):ansistring;

function bip39toEntropy(bip39:string):ansistring;
function BitstoEntropy(bits:ansistring):ansistring;

function bytesToBIP39(buf:ansistring;const bipArray:array of string;separator:string=' '):string;
function checkEntropy(buf:ansistring):boolean;

implementation
uses math, {UOpenSSL, UOpenSSLdef,} {LazUTF8,} Crypto, CryptoLib4PascalConnectorUnit

  ,ClpIX9ECParameters
  ,ClpIECDomainParameters
  ,ClpECDomainParameters
  ,ClpIECKeyPairGenerator
  ,ClpIECKeyGenerationParameters
  ,ClpBigInteger
  ,ClpCustomNamedCurves
  ,HlpHashFactory
  ,ClpIECInterface

  ,HlpIHash
  ,HlpIHashInfo
 // ,HlpConverters
  ,HDNodeUnit

//  , MainUnit
  , Localizzzeunit
  ;

//--------------------------------lasUTF8 copy
function UTF8CharacterLengthFull(p: PChar): integer;
begin
  case p^ of
  #0..#191: // %11000000
    // regular single byte character (#0 is a character, this is Pascal ;)
    Result:=1;
  #192..#223: // p^ and %11100000 = %11000000
    begin
      // could be 2 byte character
      if (ord(p[1]) and %11000000) = %10000000 then
        Result:=2
      else
        Result:=1;
    end;
  #224..#239: // p^ and %11110000 = %11100000
    begin
      // could be 3 byte character
      if ((ord(p[1]) and %11000000) = %10000000)
      and ((ord(p[2]) and %11000000) = %10000000) then
        Result:=3
      else
        Result:=1;
    end;
  #240..#247: // p^ and %11111000 = %11110000
    begin
      // could be 4 byte character
      if ((ord(p[1]) and %11000000) = %10000000)
      and ((ord(p[2]) and %11000000) = %10000000)
      and ((ord(p[3]) and %11000000) = %10000000) then
        Result:=4
      else
        Result:=1;
    end;
  else
    Result:=1;
  end;
end;

function UTF8CharacterLength(p: PChar): integer; inline;
begin
  if p=nil then exit(0);
  if p^<#192 then exit(1);
  Result:=UTF8CharacterLengthFull(p);
end;

function UTF8Length(p: PChar; ByteCount: PtrInt): PtrInt;
var
  CharLen: LongInt;
begin
  Result:=0;
  while (ByteCount>0) do begin
    inc(Result);
    CharLen:=UTF8CharacterLength(p);
    inc(p,CharLen);
    dec(ByteCount,CharLen);
  end;
end;

function UTF8Length(const s: string): PtrInt;
begin
  Result:=UTF8Length(PChar(s),length(s));
end;

function UTF8CharacterToUnicode(p: PChar; out CharLen: integer): Cardinal;
{ if p=nil then CharLen=0 otherwise CharLen>0
  If there is an encoding error the Result is 0 and CharLen=1.
  Use UTF8FixBroken to fix UTF-8 encoding.
  It does not check if the codepoint is defined in the Unicode tables.
}
begin
  if p<>nil then begin
    if ord(p^)<%11000000 then begin
      // regular single byte character (#0 is a normal char, this is pascal ;)
      Result:=ord(p^);
      CharLen:=1;
    end
    else if ((ord(p^) and %11100000) = %11000000) then begin
      // starts with %110 => could be double byte character
      if (ord(p[1]) and %11000000) = %10000000 then begin
        CharLen:=2;
        Result:=((ord(p^) and %00011111) shl 6) or (ord(p[1]) and %00111111);
        if Result<(1 shl 7) then begin
          // wrong encoded, could be an XSS attack
          Result:=0;
        end;
      end else begin
        Result:=ord(p^);
        CharLen:=1;
      end;
    end
    else if ((ord(p^) and %11110000) = %11100000) then begin
      // starts with %1110 => could be triple byte character
      if ((ord(p[1]) and %11000000) = %10000000)
      and ((ord(p[2]) and %11000000) = %10000000) then begin
        CharLen:=3;
        Result:=((ord(p^) and %00011111) shl 12)
                or ((ord(p[1]) and %00111111) shl 6)
                or (ord(p[2]) and %00111111);
        if Result<(1 shl 11) then begin
          // wrong encoded, could be an XSS attack
          Result:=0;
        end;
      end else begin
        Result:=ord(p^);
        CharLen:=1;
      end;
    end
    else if ((ord(p^) and %11111000) = %11110000) then begin
      // starts with %11110 => could be 4 byte character
      if ((ord(p[1]) and %11000000) = %10000000)
      and ((ord(p[2]) and %11000000) = %10000000)
      and ((ord(p[3]) and %11000000) = %10000000) then begin
        CharLen:=4;
        Result:=((ord(p^) and %00001111) shl 18)
                or ((ord(p[1]) and %00111111) shl 12)
                or ((ord(p[2]) and %00111111) shl 6)
                or (ord(p[3]) and %00111111);
        if Result<(1 shl 16) then begin
          // wrong encoded, could be an XSS attack
          Result:=0;
        end;
      end else begin
        Result:=ord(p^);
        CharLen:=1;
      end;
    end
    else begin
      // invalid character
      Result:=ord(p^);
      CharLen:=1;
    end;
  end else begin
    Result:=0;
    CharLen:=0;
  end;
end;

function UTF8UpperCase(const AInStr: string; ALanguage: string=''): string;
var
  i, InCounter, OutCounter: PtrInt;
  OutStr: PChar;
  CharLen: integer;
  CharProcessed: Boolean;
  NewCharLen: integer;
  NewChar, OldChar: Word;
  // Language identification
  IsTurkish: Boolean;

  procedure CorrectOutStrSize(AOldCharSize, ANewCharSize: Integer);
  begin
    if not (ANewCharSize > AOldCharSize) then Exit; // no correction needed
    if (ANewCharSize > 20) or (AOldCharSize > 20) then Exit; // sanity check
    // Fix for bug 23428
    // If the string wasn't decreased by previous char changes,
    // and our current operation will make it bigger, then for safety
    // increase the buffer
    if (ANewCharSize > AOldCharSize) and (OutCounter >= InCounter-1) then
    begin
      SetLength(Result, Length(Result)+ANewCharSize-AOldCharSize);
      OutStr := PChar(Result);
    end;
  end;

begin
  // Start with the same string, and progressively modify
  Result:=AInStr;
  UniqueString(Result);
  OutStr := PChar(Result);

  // Language identification
  IsTurkish := (ALanguage = 'tr') or (ALanguage = 'az'); // Turkish and Azeri have a special handling

  InCounter:=1; // for AInStr
  OutCounter := 0; // for Result
  while InCounter<=length(AInStr) do
  begin
    { First ASCII chars }
    if (AInStr[InCounter] <= 'z') and (AInStr[InCounter] >= 'a') then
    begin
      // Special turkish handling
      // small dotted i to capital dotted i
      if IsTurkish and (AInStr[InCounter] = 'i') then
      begin
        SetLength(Result,Length(Result)+1);// Increase the buffer
        OutStr := PChar(Result);
        OutStr[OutCounter]:=#$C4;
        OutStr[OutCounter+1]:=#$B0;
        inc(InCounter);
        inc(OutCounter,2);
      end
      else
      begin
        OutStr[OutCounter]:=chr(ord(AInStr[InCounter])-32);
        inc(InCounter);
        inc(OutCounter);
      end;
    end
    { Now everything else }
    else
    begin
      CharLen := UTF8CharacterLength(@AInStr[InCounter]);
      CharProcessed := False;
      NewCharLen := CharLen;

      if CharLen = 2 then
      begin
        OldChar := (Ord(AInStr[InCounter]) shl 8) or Ord(AInStr[InCounter+1]);
        NewChar := 0;

        // Major processing
        case OldChar of
        // Latin Characters 0000–0FFF http://en.wikibooks.org/wiki/Unicode/Character_reference/0000-0FFF
        $C39F:        NewChar := $5353; // ß => SS
        $C3A0..$C3B6,$C3B8..$C3BE: NewChar := OldChar - $20;
        $C3BF:        NewChar := $C5B8; // ÿ
        $C481..$C4B0: if OldChar mod 2 = 1 then NewChar := OldChar - 1;
        // 0130 = C4 B0
        // turkish small undotted i to capital undotted i
        $C4B1:
        begin
          OutStr[OutCounter]:='I';
          NewCharLen := 1;
          CharProcessed := True;
        end;
        $C4B2..$C4B7: if OldChar mod 2 = 1 then NewChar := OldChar - 1;
        // $C4B8: ĸ without upper/lower
        $C4B9..$C4BF: if OldChar mod 2 = 0 then NewChar := OldChar - 1;
        $C580: NewChar := $C4BF; // border between bytes
        $C581..$C588: if OldChar mod 2 = 0 then NewChar := OldChar - 1;
        // $C589 ŉ => ?
        $C58A..$C5B7: if OldChar mod 2 = 1 then NewChar := OldChar - 1;
        // $C5B8: // Ÿ already uppercase
        $C5B9..$C5BE: if OldChar mod 2 = 0 then NewChar := OldChar - 1;
        $C5BF: // 017F
        begin
          OutStr[OutCounter]:='S';
          NewCharLen := 1;
          CharProcessed := True;
        end;
        // 0180 = C6 80 -> A convoluted part
        $C680: NewChar := $C983;
        $C682..$C685: if OldChar mod 2 = 1 then NewChar := OldChar - 1;
        $C688: NewChar := $C687;
        $C68C: NewChar := $C68B;
        // 0190 = C6 90 -> A convoluted part
        $C692: NewChar := $C691;
        $C695: NewChar := $C7B6;
        $C699: NewChar := $C698;
        $C69A: NewChar := $C8BD;
        $C69E: NewChar := $C8A0;
        // 01A0 = C6 A0 -> A convoluted part
        $C6A0..$C6A5: if OldChar mod 2 = 1 then NewChar := OldChar - 1;
        $C6A8: NewChar := $C6A7;
        $C6AD: NewChar := $C6AC;
        // 01B0 = C6 B0
        $C6B0: NewChar := $C6AF;
        $C6B3..$C6B6: if OldChar mod 2 = 0 then NewChar := OldChar - 1;
        $C6B9: NewChar := $C6B8;
        $C6BD: NewChar := $C6BC;
        $C6BF: NewChar := $C7B7;
        // 01C0 = C7 80
        $C784..$C786: NewChar := $C784;
        $C787..$C789: NewChar := $C787;
        $C78A..$C78C: NewChar := $C78A;
        $C78E: NewChar := $C78D;
        // 01D0 = C7 90
        $C790: NewChar := $C78F;
        $C791..$C79C: if OldChar mod 2 = 0 then NewChar := OldChar - 1;
        $C79D: NewChar := $C68E;
        $C79F: NewChar := $C79E;
        // 01E0 = C7 A0
        $C7A0..$C7AF: if OldChar mod 2 = 1 then NewChar := OldChar - 1;
        // 01F0 = C7 B0
        $C7B2..$C7B3: NewChar := $C7B1;
        $C7B5: NewChar := $C7B4;
        $C7B8..$C7BF: if OldChar mod 2 = 1 then NewChar := OldChar - 1;
        // 0200 = C8 80
        // 0210 = C8 90
        $C880..$C89F: if OldChar mod 2 = 1 then NewChar := OldChar - 1;
        // 0220 = C8 A0
        // 0230 = C8 B0
        $C8A2..$C8B3: if OldChar mod 2 = 1 then NewChar := OldChar - 1;
        $C8BC: NewChar := $C8BB;
        $C8BF:
        begin
          CorrectOutStrSize(2, 3);
          OutStr[OutCounter]  := #$E2;
          OutStr[OutCounter+1]:= #$B1;
          OutStr[OutCounter+2]:= #$BE;
          NewCharLen := 3;
          CharProcessed := True;
        end;
        // 0240 = C9 80
        $C980:
        begin
          CorrectOutStrSize(2, 3);
          OutStr[OutCounter]  := #$E2;
          OutStr[OutCounter+1]:= #$B1;
          OutStr[OutCounter+2]:= #$BF;
          NewCharLen := 3;
          CharProcessed := True;
        end;
        $C982: NewChar := $C981;
        $C986..$C98F: if OldChar mod 2 = 1 then NewChar := OldChar - 1;
        // 0250 = C9 90
        $C990:
        begin
          CorrectOutStrSize(2, 3);
          OutStr[OutCounter]  := #$E2;
          OutStr[OutCounter+1]:= #$B1;
          OutStr[OutCounter+2]:= #$AF;
          NewCharLen := 3;
          CharProcessed := True;
        end;
        $C991:
        begin
          CorrectOutStrSize(2, 3);
          OutStr[OutCounter]  := #$E2;
          OutStr[OutCounter+1]:= #$B1;
          OutStr[OutCounter+2]:= #$AD;
          NewCharLen := 3;
          CharProcessed := True;
        end;
        $C992:
        begin
          CorrectOutStrSize(2, 3);
          OutStr[OutCounter]  := #$E2;
          OutStr[OutCounter+1]:= #$B1;
          OutStr[OutCounter+2]:= #$B0;
          NewCharLen := 3;
          CharProcessed := True;
        end;
        $C993: NewChar := $C681;
        $C994: NewChar := $C686;
        $C996: NewChar := $C689;
        $C997: NewChar := $C68A;
        $C999: NewChar := $C68F;
        $C99B: NewChar := $C690;
        // 0260 = C9 A0
        $C9A0: NewChar := $C693;
        $C9A3: NewChar := $C694;
        $C9A5:
        begin
          CorrectOutStrSize(2, 3);
          OutStr[OutCounter]  := #$EA;
          OutStr[OutCounter+1]:= #$9E;
          OutStr[OutCounter+2]:= #$8D;
          NewCharLen := 3;
          CharProcessed := True;
        end;
        $C9A8: NewChar := $C697;
        $C9A9: NewChar := $C696;
        $C9AB:
        begin
          CorrectOutStrSize(2, 3);
          OutStr[OutCounter]  := #$E2;
          OutStr[OutCounter+1]:= #$B1;
          OutStr[OutCounter+2]:= #$A2;
          NewCharLen := 3;
          CharProcessed := True;
        end;
        $C9AF: NewChar := $C69C;
        // 0270 = C9 B0
        $C9B1:
        begin
          CorrectOutStrSize(2, 3);
          OutStr[OutCounter]  := #$E2;
          OutStr[OutCounter+1]:= #$B1;
          OutStr[OutCounter+2]:= #$AE;
          NewCharLen := 3;
          CharProcessed := True;
        end;
        $C9B2: NewChar := $C69D;
        $C9B5: NewChar := $C69F;
        $C9BD:
        begin
          CorrectOutStrSize(2, 3);
          OutStr[OutCounter]  := #$E2;
          OutStr[OutCounter+1]:= #$B1;
          OutStr[OutCounter+2]:= #$A4;
          NewCharLen := 3;
          CharProcessed := True;
        end;
        // 0280 = CA 80
        $CA80: NewChar := $C6A6;
        $CA83: NewChar := $C6A9;
        $CA88: NewChar := $C6AE;
        $CA89: NewChar := $C984;
        $CA8A: NewChar := $C6B1;
        $CA8B: NewChar := $C6B2;
        $CA8C: NewChar := $C985;
        // 0290 = CA 90
        $CA92: NewChar := $C6B7;
        {
        03A0 = CE A0

        03AC;GREEK SMALL LETTER ALPHA WITH TONOS;Ll;0;L;03B1 0301;;;;N;GREEK SMALL LETTER ALPHA TONOS;;0386;;0386
        03AD;GREEK SMALL LETTER EPSILON WITH TONOS;Ll;0;L;03B5 0301;;;;N;GREEK SMALL LETTER EPSILON TONOS;;0388;;0388
        03AE;GREEK SMALL LETTER ETA WITH TONOS;Ll;0;L;03B7 0301;;;;N;GREEK SMALL LETTER ETA TONOS;;0389;;0389
        03AF;GREEK SMALL LETTER IOTA WITH TONOS;Ll;0;L;03B9 0301;;;;N;GREEK SMALL LETTER IOTA TONOS;;038A;;038A
        }
        $CEAC: NewChar := $CE86;
        $CEAD: NewChar := $CE88;
        $CEAE: NewChar := $CE89;
        $CEAF: NewChar := $CE8A;
        {
        03B0 = CE B0

        03B0;GREEK SMALL LETTER UPSILON WITH DIALYTIKA AND TONOS;Ll;0;L;03CB 0301;;;;N;GREEK SMALL LETTER UPSILON DIAERESIS TONOS;;;;
        03B1;GREEK SMALL LETTER ALPHA;Ll;0;L;;;;;N;;;0391;;0391
        ...
        03BF;GREEK SMALL LETTER OMICRON;Ll;0;L;;;;;N;;;039F;;039F
        }
        $CEB1..$CEBF: NewChar := OldChar - $20; // Greek Characters
        {
        03C0 = CF 80

        03C0;GREEK SMALL LETTER PI;Ll;0;L;;;;;N;;;03A0;;03A0 CF 80 => CE A0
        03C1;GREEK SMALL LETTER RHO;Ll;0;L;;;;;N;;;03A1;;03A1
        03C2;GREEK SMALL LETTER FINAL SIGMA;Ll;0;L;;;;;N;;;03A3;;03A3
        03C3;GREEK SMALL LETTER SIGMA;Ll;0;L;;;;;N;;;03A3;;03A3
        03C4;GREEK SMALL LETTER TAU;Ll;0;L;;;;;N;;;03A4;;03A4
        ....
        03CB;GREEK SMALL LETTER UPSILON WITH DIALYTIKA;Ll;0;L;03C5 0308;;;;N;GREEK SMALL LETTER UPSILON DIAERESIS;;03AB;;03AB
        03CC;GREEK SMALL LETTER OMICRON WITH TONOS;Ll;0;L;03BF 0301;;;;N;GREEK SMALL LETTER OMICRON TONOS;;038C;;038C
        03CD;GREEK SMALL LETTER UPSILON WITH TONOS;Ll;0;L;03C5 0301;;;;N;GREEK SMALL LETTER UPSILON TONOS;;038E;;038E
        03CE;GREEK SMALL LETTER OMEGA WITH TONOS;Ll;0;L;03C9 0301;;;;N;GREEK SMALL LETTER OMEGA TONOS;;038F;;038F
        03CF;GREEK CAPITAL KAI SYMBOL;Lu;0;L;;;;;N;;;;03D7;
        }
        $CF80,$CF81,$CF83..$CF8B: NewChar := OldChar - $E0; // Greek Characters
        $CF82: NewChar := $CEA3;
        $CF8C: NewChar := $CE8C;
        $CF8D: NewChar := $CE8E;
        $CF8E: NewChar := $CE8F;
        {
        03D0 = CF 90

        03D0;GREEK BETA SYMBOL;Ll;0;L;<compat> 03B2;;;;N;GREEK SMALL LETTER CURLED BETA;;0392;;0392 CF 90 => CE 92
        03D1;GREEK THETA SYMBOL;Ll;0;L;<compat> 03B8;;;;N;GREEK SMALL LETTER SCRIPT THETA;;0398;;0398 => CE 98
        03D5;GREEK PHI SYMBOL;Ll;0;L;<compat> 03C6;;;;N;GREEK SMALL LETTER SCRIPT PHI;;03A6;;03A6 => CE A6
        03D6;GREEK PI SYMBOL;Ll;0;L;<compat> 03C0;;;;N;GREEK SMALL LETTER OMEGA PI;;03A0;;03A0 => CE A0
        03D7;GREEK KAI SYMBOL;Ll;0;L;;;;;N;;;03CF;;03CF => CF 8F
        03D9;GREEK SMALL LETTER ARCHAIC KOPPA;Ll;0;L;;;;;N;;;03D8;;03D8
        03DB;GREEK SMALL LETTER STIGMA;Ll;0;L;;;;;N;;;03DA;;03DA
        03DD;GREEK SMALL LETTER DIGAMMA;Ll;0;L;;;;;N;;;03DC;;03DC
        03DF;GREEK SMALL LETTER KOPPA;Ll;0;L;;;;;N;;;03DE;;03DE
        }
        $CF90: NewChar := $CE92;
        $CF91: NewChar := $CE98;
        $CF95: NewChar := $CEA6;
        $CF96: NewChar := $CEA0;
        $CF97: NewChar := $CF8F;
        $CF99..$CF9F: if OldChar mod 2 = 1 then NewChar := OldChar - 1;
        // 03E0 = CF A0
        $CFA0..$CFAF: if OldChar mod 2 = 1 then NewChar := OldChar - 1;
        {
        03F0 = CF B0

        03F0;GREEK KAPPA SYMBOL;Ll;0;L;<compat> 03BA;;;;N;GREEK SMALL LETTER SCRIPT KAPPA;;039A;;039A => CE 9A
        03F1;GREEK RHO SYMBOL;Ll;0;L;<compat> 03C1;;;;N;GREEK SMALL LETTER TAILED RHO;;03A1;;03A1 => CE A1
        03F2;GREEK LUNATE SIGMA SYMBOL;Ll;0;L;<compat> 03C2;;;;N;GREEK SMALL LETTER LUNATE SIGMA;;03F9;;03F9
        03F5;GREEK LUNATE EPSILON SYMBOL;Ll;0;L;<compat> 03B5;;;;N;;;0395;;0395 => CE 95
        03F8;GREEK SMALL LETTER SHO;Ll;0;L;;;;;N;;;03F7;;03F7
        03FB;GREEK SMALL LETTER SAN;Ll;0;L;;;;;N;;;03FA;;03FA
        }
        $CFB0: NewChar := $CE9A;
        $CFB1: NewChar := $CEA1;
        $CFB2: NewChar := $CFB9;
        $CFB5: NewChar := $CE95;
        $CFB8: NewChar := $CFB7;
        $CFBB: NewChar := $CFBA;
        // 0400 = D0 80 ... 042F everything already uppercase
        // 0430 = D0 B0
        $D0B0..$D0BF: NewChar := OldChar - $20; // Cyrillic alphabet
        // 0440 = D1 80
        $D180..$D18F: NewChar := OldChar - $E0; // Cyrillic alphabet
        // 0450 = D1 90
        $D190..$D19F: NewChar := OldChar - $110; // Cyrillic alphabet
        end;

        if NewChar <> 0 then
        begin
          OutStr[OutCounter]  := Chr(Hi(NewChar));
          OutStr[OutCounter+1]:= Chr(Lo(NewChar));
          CharProcessed := True;
        end;
      end;

      // Copy the character if the string was disaligned by previous changed
      // and no processing was done in this character
      if (InCounter <> OutCounter+1) and (not CharProcessed) then
      begin
        for i := 0 to CharLen-1 do
          OutStr[OutCounter+i]  :=AInStr[InCounter+i];
      end;

      inc(InCounter, CharLen);
      inc(OutCounter, NewCharLen);
    end;
  end; // while

  // Final correction of the buffer size
  SetLength(Result,OutCounter);
end;

function UTF8LowerCase(const AInStr: string; ALanguage: string=''): string;
var
  CounterDiff: PtrInt;
  InStr, InStrEnd, OutStr: PChar;
  // Language identification
  IsTurkish: Boolean;
  c1, c2, c3, new_c1, new_c2, new_c3: Char;
  p: SizeInt;
begin
  Result:=AInStr;
  InStr := PChar(AInStr);
  InStrEnd := InStr + length(AInStr); // points behind last char

  // Do a fast initial parsing of the string to maybe avoid doing
  // UniqueString if the resulting string will be identical
  while (InStr < InStrEnd) do
  begin
    c1 := InStr^;
    case c1 of
    'A'..'Z': Break;
    #$C3..#$FF:
      case c1 of
      #$C3..#$C9, #$CE, #$CF, #$D0..#$D5, #$E1..#$E2,#$E5:
        begin
          c2 := InStr[1];
          case c1 of
          #$C3: if c2 in [#$80..#$9E] then Break;
          #$C4:
          begin
            case c2 of
            #$80..#$AF, #$B2..#$B6: if ord(c2) mod 2 = 0 then Break;
            #$B8..#$FF: if ord(c2) mod 2 = 1 then Break;
            #$B0: Break;
            end;
          end;
          #$C5:
          begin
            case c2 of
              #$8A..#$B7: if ord(c2) mod 2 = 0 then Break;
              #$00..#$88, #$B9..#$FF: if ord(c2) mod 2 = 1 then Break;
              #$B8: Break;
            end;
          end;
          // Process E5 to avoid stopping on chinese chars
          #$E5: if (c2 = #$BC) and (InStr[2] in [#$A1..#$BA]) then Break;
          // Others are too complex, better not to pre-inspect them
          else
            Break;
          end;
          // already lower, or otherwhise not affected
        end;
      end;
    end;
    inc(InStr);
  end;

  if InStr >= InStrEnd then Exit;

  // Language identification
  IsTurkish := (ALanguage = 'tr') or (ALanguage = 'az'); // Turkish and Azeri have a special handling

  UniqueString(Result);
  OutStr := PChar(Result) + (InStr - PChar(AInStr));
  CounterDiff := 0;

  while InStr < InStrEnd do
  begin
    c1 := InStr^;
    case c1 of
      // codepoints      UTF-8 range           Description                Case change
      // $0041..$005A    $41..$5A              Capital ASCII              X+$20
      'A'..'Z':
      begin
        { First ASCII chars }
        // Special turkish handling
        // capital undotted I to small undotted i
        if IsTurkish and (c1 = 'I') then
        begin
          p:=OutStr - PChar(Result);
          SetLength(Result,Length(Result)+1);// Increase the buffer
          OutStr := PChar(Result)+p;
          OutStr^ := #$C4;
          inc(OutStr);
          OutStr^ := #$B1;
          dec(CounterDiff);
        end
        else
        begin
          OutStr^ := chr(ord(c1)+32);
        end;
        inc(InStr);
        inc(OutStr);
      end;

      // Chars with 2-bytes which might be modified
      #$C3..#$D5:
      begin
        c2 := InStr[1];
        new_c1 := c1;
        new_c2 := c2;
        case c1 of
        // Latin Characters 0000–0FFF http://en.wikibooks.org/wiki/Unicode/Character_reference/0000-0FFF
        // codepoints      UTF-8 range           Description                Case change
        // $00C0..$00D6    C3 80..C3 96          Capital Latin with accents X+$20
        // $D7             C3 97                 Multiplication Sign        N/A
        // $00D8..$00DE    C3 98..C3 9E          Capital Latin with accents X+$20
        // $DF             C3 9F                 German beta ß              already lowercase
        #$C3:
        begin
          case c2 of
          #$80..#$96, #$98..#$9E: new_c2 := chr(ord(c2) + $20)
          end;
        end;
        // $0100..$012F    C4 80..C4 AF        Capital/Small Latin accents  if mod 2 = 0 then X+1
        // $0130..$0131    C4 B0..C4 B1        Turkish
        //  C4 B0 turkish uppercase dotted i -> 'i'
        //  C4 B1 turkish lowercase undotted ı
        // $0132..$0137    C4 B2..C4 B7        Capital/Small Latin accents  if mod 2 = 0 then X+1
        // $0138           C4 B8               ĸ                            N/A
        // $0139..$024F    C4 B9..C5 88        Capital/Small Latin accents  if mod 2 = 1 then X+1
        #$C4:
        begin
          case c2 of
            #$80..#$AF, #$B2..#$B7: if ord(c2) mod 2 = 0 then new_c2 := chr(ord(c2) + 1);
            #$B0: // Turkish
            begin
              OutStr^ := 'i';
              inc(InStr, 2);
              inc(OutStr);
              inc(CounterDiff, 1);
              Continue;
            end;
            #$B9..#$BE: if ord(c2) mod 2 = 1 then new_c2 := chr(ord(c2) + 1);
            #$BF: // This crosses the borders between the first byte of the UTF-8 char
            begin
              new_c1 := #$C5;
              new_c2 := #$80;
            end;
          end;
        end;
        // $C589 ŉ
        // $C58A..$C5B7: if OldChar mod 2 = 0 then NewChar := OldChar + 1;
        // $C5B8:        NewChar := $C3BF; // Ÿ
        // $C5B9..$C8B3: if OldChar mod 2 = 1 then NewChar := OldChar + 1;
        #$C5:
        begin
          case c2 of
            #$8A..#$B7: //0
            begin
              if ord(c2) mod 2 = 0 then
                new_c2 := chr(ord(c2) + 1);
            end;
            #$00..#$88, #$B9..#$BE: //1
            begin
              if ord(c2) mod 2 = 1 then
                new_c2 := chr(ord(c2) + 1);
            end;
            #$B8:  // Ÿ
            begin
              new_c1 := #$C3;
              new_c2 := #$BF;
            end;
          end;
        end;
        {A convoluted part: C6 80..C6 8F

        0180;LATIN SMALL LETTER B WITH STROKE;Ll;0;L;;;;;N;LATIN SMALL LETTER B BAR;;0243;;0243
        0181;LATIN CAPITAL LETTER B WITH HOOK;Lu;0;L;;;;;N;LATIN CAPITAL LETTER B HOOK;;;0253; => C6 81=>C9 93
        0182;LATIN CAPITAL LETTER B WITH TOPBAR;Lu;0;L;;;;;N;LATIN CAPITAL LETTER B TOPBAR;;;0183;
        0183;LATIN SMALL LETTER B WITH TOPBAR;Ll;0;L;;;;;N;LATIN SMALL LETTER B TOPBAR;;0182;;0182
        0184;LATIN CAPITAL LETTER TONE SIX;Lu;0;L;;;;;N;;;;0185;
        0185;LATIN SMALL LETTER TONE SIX;Ll;0;L;;;;;N;;;0184;;0184
        0186;LATIN CAPITAL LETTER OPEN O;Lu;0;L;;;;;N;;;;0254; ==> C9 94
        0187;LATIN CAPITAL LETTER C WITH HOOK;Lu;0;L;;;;;N;LATIN CAPITAL LETTER C HOOK;;;0188;
        0188;LATIN SMALL LETTER C WITH HOOK;Ll;0;L;;;;;N;LATIN SMALL LETTER C HOOK;;0187;;0187
        0189;LATIN CAPITAL LETTER AFRICAN D;Lu;0;L;;;;;N;;;;0256; => C9 96
        018A;LATIN CAPITAL LETTER D WITH HOOK;Lu;0;L;;;;;N;LATIN CAPITAL LETTER D HOOK;;;0257; => C9 97
        018B;LATIN CAPITAL LETTER D WITH TOPBAR;Lu;0;L;;;;;N;LATIN CAPITAL LETTER D TOPBAR;;;018C;
        018C;LATIN SMALL LETTER D WITH TOPBAR;Ll;0;L;;;;;N;LATIN SMALL LETTER D TOPBAR;;018B;;018B
        018D;LATIN SMALL LETTER TURNED DELTA;Ll;0;L;;;;;N;;;;;
        018E;LATIN CAPITAL LETTER REVERSED E;Lu;0;L;;;;;N;LATIN CAPITAL LETTER TURNED E;;;01DD; => C7 9D
        018F;LATIN CAPITAL LETTER SCHWA;Lu;0;L;;;;;N;;;;0259; => C9 99
        }
        #$C6:
        begin
          case c2 of
            #$81:
            begin
              new_c1 := #$C9;
              new_c2 := #$93;
            end;
            #$82..#$85:
            begin
              if ord(c2) mod 2 = 0 then
                new_c2 := chr(ord(c2) + 1);
            end;
            #$87..#$88,#$8B..#$8C:
            begin
              if ord(c2) mod 2 = 1 then
                new_c2 := chr(ord(c2) + 1);
            end;
            #$86:
            begin
              new_c1 := #$C9;
              new_c2 := #$94;
            end;
            #$89:
            begin
              new_c1 := #$C9;
              new_c2 := #$96;
            end;
            #$8A:
            begin
              new_c1 := #$C9;
              new_c2 := #$97;
            end;
            #$8E:
            begin
              new_c1 := #$C7;
              new_c2 := #$9D;
            end;
            #$8F:
            begin
              new_c1 := #$C9;
              new_c2 := #$99;
            end;
          {
          And also C6 90..C6 9F

          0190;LATIN CAPITAL LETTER OPEN E;Lu;0;L;;;;;N;LATIN CAPITAL LETTER EPSILON;;;025B; => C9 9B
          0191;LATIN CAPITAL LETTER F WITH HOOK;Lu;0;L;;;;;N;LATIN CAPITAL LETTER F HOOK;;;0192; => +1
          0192;LATIN SMALL LETTER F WITH HOOK;Ll;0;L;;;;;N;LATIN SMALL LETTER SCRIPT F;;0191;;0191 <=
          0193;LATIN CAPITAL LETTER G WITH HOOK;Lu;0;L;;;;;N;LATIN CAPITAL LETTER G HOOK;;;0260; => C9 A0
          0194;LATIN CAPITAL LETTER GAMMA;Lu;0;L;;;;;N;;;;0263; => C9 A3
          0195;LATIN SMALL LETTER HV;Ll;0;L;;;;;N;LATIN SMALL LETTER H V;;01F6;;01F6 <=
          0196;LATIN CAPITAL LETTER IOTA;Lu;0;L;;;;;N;;;;0269; => C9 A9
          0197;LATIN CAPITAL LETTER I WITH STROKE;Lu;0;L;;;;;N;LATIN CAPITAL LETTER BARRED I;;;0268; => C9 A8
          0198;LATIN CAPITAL LETTER K WITH HOOK;Lu;0;L;;;;;N;LATIN CAPITAL LETTER K HOOK;;;0199; => +1
          0199;LATIN SMALL LETTER K WITH HOOK;Ll;0;L;;;;;N;LATIN SMALL LETTER K HOOK;;0198;;0198 <=
          019A;LATIN SMALL LETTER L WITH BAR;Ll;0;L;;;;;N;LATIN SMALL LETTER BARRED L;;023D;;023D <=
          019B;LATIN SMALL LETTER LAMBDA WITH STROKE;Ll;0;L;;;;;N;LATIN SMALL LETTER BARRED LAMBDA;;;; <=
          019C;LATIN CAPITAL LETTER TURNED M;Lu;0;L;;;;;N;;;;026F; => C9 AF
          019D;LATIN CAPITAL LETTER N WITH LEFT HOOK;Lu;0;L;;;;;N;LATIN CAPITAL LETTER N HOOK;;;0272; => C9 B2
          019E;LATIN SMALL LETTER N WITH LONG RIGHT LEG;Ll;0;L;;;;;N;;;0220;;0220 <=
          019F;LATIN CAPITAL LETTER O WITH MIDDLE TILDE;Lu;0;L;;;;;N;LATIN CAPITAL LETTER BARRED O;;;0275; => C9 B5
          }
          #$90:
          begin
            new_c1 := #$C9;
            new_c2 := #$9B;
          end;
          #$91, #$98: new_c2 := chr(ord(c2)+1);
          #$93:
          begin
            new_c1 := #$C9;
            new_c2 := #$A0;
          end;
          #$94:
          begin
            new_c1 := #$C9;
            new_c2 := #$A3;
          end;
          #$96:
          begin
            new_c1 := #$C9;
            new_c2 := #$A9;
          end;
          #$97:
          begin
            new_c1 := #$C9;
            new_c2 := #$A8;
          end;
          #$9C:
          begin
            new_c1 := #$C9;
            new_c2 := #$AF;
          end;
          #$9D:
          begin
            new_c1 := #$C9;
            new_c2 := #$B2;
          end;
          #$9F:
          begin
            new_c1 := #$C9;
            new_c2 := #$B5;
          end;
          {
          And also C6 A0..C6 AF

          01A0;LATIN CAPITAL LETTER O WITH HORN;Lu;0;L;004F 031B;;;;N;LATIN CAPITAL LETTER O HORN;;;01A1; => +1
          01A1;LATIN SMALL LETTER O WITH HORN;Ll;0;L;006F 031B;;;;N;LATIN SMALL LETTER O HORN;;01A0;;01A0 <=
          01A2;LATIN CAPITAL LETTER OI;Lu;0;L;;;;;N;LATIN CAPITAL LETTER O I;;;01A3; => +1
          01A3;LATIN SMALL LETTER OI;Ll;0;L;;;;;N;LATIN SMALL LETTER O I;;01A2;;01A2 <=
          01A4;LATIN CAPITAL LETTER P WITH HOOK;Lu;0;L;;;;;N;LATIN CAPITAL LETTER P HOOK;;;01A5; => +1
          01A5;LATIN SMALL LETTER P WITH HOOK;Ll;0;L;;;;;N;LATIN SMALL LETTER P HOOK;;01A4;;01A4 <=
          01A6;LATIN LETTER YR;Lu;0;L;;;;;N;LATIN LETTER Y R;;;0280; => CA 80
          01A7;LATIN CAPITAL LETTER TONE TWO;Lu;0;L;;;;;N;;;;01A8; => +1
          01A8;LATIN SMALL LETTER TONE TWO;Ll;0;L;;;;;N;;;01A7;;01A7 <=
          01A9;LATIN CAPITAL LETTER ESH;Lu;0;L;;;;;N;;;;0283; => CA 83
          01AA;LATIN LETTER REVERSED ESH LOOP;Ll;0;L;;;;;N;;;;;
          01AB;LATIN SMALL LETTER T WITH PALATAL HOOK;Ll;0;L;;;;;N;LATIN SMALL LETTER T PALATAL HOOK;;;; <=
          01AC;LATIN CAPITAL LETTER T WITH HOOK;Lu;0;L;;;;;N;LATIN CAPITAL LETTER T HOOK;;;01AD; => +1
          01AD;LATIN SMALL LETTER T WITH HOOK;Ll;0;L;;;;;N;LATIN SMALL LETTER T HOOK;;01AC;;01AC <=
          01AE;LATIN CAPITAL LETTER T WITH RETROFLEX HOOK;Lu;0;L;;;;;N;LATIN CAPITAL LETTER T RETROFLEX HOOK;;;0288; => CA 88
          01AF;LATIN CAPITAL LETTER U WITH HORN;Lu;0;L;0055 031B;;;;N;LATIN CAPITAL LETTER U HORN;;;01B0; => +1
          }
          #$A0..#$A5,#$AC:
          begin
            if ord(c2) mod 2 = 0 then
              new_c2 := chr(ord(c2) + 1);
          end;
          #$A7,#$AF:
          begin
            if ord(c2) mod 2 = 1 then
              new_c2 := chr(ord(c2) + 1);
          end;
          #$A6:
          begin
            new_c1 := #$CA;
            new_c2 := #$80;
          end;
          #$A9:
          begin
            new_c1 := #$CA;
            new_c2 := #$83;
          end;
          #$AE:
          begin
            new_c1 := #$CA;
            new_c2 := #$88;
          end;
          {
          And also C6 B0..C6 BF

          01B0;LATIN SMALL LETTER U WITH HORN;Ll;0;L;0075 031B;;;;N;LATIN SMALL LETTER U HORN;;01AF;;01AF <= -1
          01B1;LATIN CAPITAL LETTER UPSILON;Lu;0;L;;;;;N;;;;028A; => CA 8A
          01B2;LATIN CAPITAL LETTER V WITH HOOK;Lu;0;L;;;;;N;LATIN CAPITAL LETTER SCRIPT V;;;028B; => CA 8B
          01B3;LATIN CAPITAL LETTER Y WITH HOOK;Lu;0;L;;;;;N;LATIN CAPITAL LETTER Y HOOK;;;01B4; => +1
          01B4;LATIN SMALL LETTER Y WITH HOOK;Ll;0;L;;;;;N;LATIN SMALL LETTER Y HOOK;;01B3;;01B3 <=
          01B5;LATIN CAPITAL LETTER Z WITH STROKE;Lu;0;L;;;;;N;LATIN CAPITAL LETTER Z BAR;;;01B6; => +1
          01B6;LATIN SMALL LETTER Z WITH STROKE;Ll;0;L;;;;;N;LATIN SMALL LETTER Z BAR;;01B5;;01B5 <=
          01B7;LATIN CAPITAL LETTER EZH;Lu;0;L;;;;;N;LATIN CAPITAL LETTER YOGH;;;0292; => CA 92
          01B8;LATIN CAPITAL LETTER EZH REVERSED;Lu;0;L;;;;;N;LATIN CAPITAL LETTER REVERSED YOGH;;;01B9; => +1
          01B9;LATIN SMALL LETTER EZH REVERSED;Ll;0;L;;;;;N;LATIN SMALL LETTER REVERSED YOGH;;01B8;;01B8 <=
          01BA;LATIN SMALL LETTER EZH WITH TAIL;Ll;0;L;;;;;N;LATIN SMALL LETTER YOGH WITH TAIL;;;; <=
          01BB;LATIN LETTER TWO WITH STROKE;Lo;0;L;;;;;N;LATIN LETTER TWO BAR;;;; X
          01BC;LATIN CAPITAL LETTER TONE FIVE;Lu;0;L;;;;;N;;;;01BD; => +1
          01BD;LATIN SMALL LETTER TONE FIVE;Ll;0;L;;;;;N;;;01BC;;01BC <=
          01BE;LATIN LETTER INVERTED GLOTTAL STOP WITH STROKE;Ll;0;L;;;;;N;LATIN LETTER INVERTED GLOTTAL STOP BAR;;;; X
          01BF;LATIN LETTER WYNN;Ll;0;L;;;;;N;;;01F7;;01F7  <=
          }
          #$B8,#$BC:
          begin
            if ord(c2) mod 2 = 0 then
              new_c2 := chr(ord(c2) + 1);
          end;
          #$B3..#$B6:
          begin
            if ord(c2) mod 2 = 1 then
              new_c2 := chr(ord(c2) + 1);
          end;
          #$B1:
          begin
            new_c1 := #$CA;
            new_c2 := #$8A;
          end;
          #$B2:
          begin
            new_c1 := #$CA;
            new_c2 := #$8B;
          end;
          #$B7:
          begin
            new_c1 := #$CA;
            new_c2 := #$92;
          end;
          end;
        end;
        #$C7:
        begin
          case c2 of
          #$84..#$8C,#$B1..#$B3:
          begin
            if (ord(c2) and $F) mod 3 = 1 then new_c2 := chr(ord(c2) + 2)
            else if (ord(c2) and $F) mod 3 = 2 then new_c2 := chr(ord(c2) + 1);
          end;
          #$8D..#$9C:
          begin
            if ord(c2) mod 2 = 1 then
              new_c2 := chr(ord(c2) + 1);
          end;
          #$9E..#$AF,#$B4..#$B5,#$B8..#$BF:
          begin
            if ord(c2) mod 2 = 0 then
              new_c2 := chr(ord(c2) + 1);
          end;
          {
          01F6;LATIN CAPITAL LETTER HWAIR;Lu;0;L;;;;;N;;;;0195;
          01F7;LATIN CAPITAL LETTER WYNN;Lu;0;L;;;;;N;;;;01BF;
          }
          #$B6:
          begin
            new_c1 := #$C6;
            new_c2 := #$95;
          end;
          #$B7:
          begin
            new_c1 := #$C6;
            new_c2 := #$BF;
          end;
          end;
        end;
        {
        Codepoints 0200 to 023F
        }
        #$C8:
        begin
          // For this one we can simply start with a default and override for some specifics
          if (c2 in [#$80..#$B3]) and (ord(c2) mod 2 = 0) then new_c2 := chr(ord(c2) + 1);

          case c2 of
          #$A0:
          begin
            new_c1 := #$C6;
            new_c2 := #$9E;
          end;
          #$A1: new_c2 := c2;
          {
          023A;LATIN CAPITAL LETTER A WITH STROKE;Lu;0;L;;;;;N;;;;2C65; => E2 B1 A5
          023B;LATIN CAPITAL LETTER C WITH STROKE;Lu;0;L;;;;;N;;;;023C; => +1
          023C;LATIN SMALL LETTER C WITH STROKE;Ll;0;L;;;;;N;;;023B;;023B <=
          023D;LATIN CAPITAL LETTER L WITH BAR;Lu;0;L;;;;;N;;;;019A; => C6 9A
          023E;LATIN CAPITAL LETTER T WITH DIAGONAL STROKE;Lu;0;L;;;;;N;;;;2C66; => E2 B1 A6
          023F;LATIN SMALL LETTER S WITH SWASH TAIL;Ll;0;L;;;;;N;;;2C7E;;2C7E <=
          0240;LATIN SMALL LETTER Z WITH SWASH TAIL;Ll;0;L;;;;;N;;;2C7F;;2C7F <=
          }
          #$BA,#$BE:
          begin
            p:= OutStr - PChar(Result);
            SetLength(Result,Length(Result)+1);// Increase the buffer
            OutStr := PChar(Result)+p;
            OutStr^ := #$E2;
            inc(OutStr);
            OutStr^ := #$B1;
            inc(OutStr);
            if c2 = #$BA then OutStr^ := #$A5
            else OutStr^ := #$A6;
            dec(CounterDiff);
            inc(OutStr);
            inc(InStr, 2);
            Continue;
          end;
          #$BD:
          begin
            new_c1 := #$C6;
            new_c2 := #$9A;
          end;
          #$BB: new_c2 := chr(ord(c2) + 1);
          end;
        end;
        {
        Codepoints 0240 to 027F

        Here only 0240..024F needs lowercase
        }
        #$C9:
        begin
          case c2 of
          #$81..#$82:
          begin
            if ord(c2) mod 2 = 1 then
              new_c2 := chr(ord(c2) + 1);
          end;
          #$86..#$8F:
          begin
            if ord(c2) mod 2 = 0 then
              new_c2 := chr(ord(c2) + 1);
          end;
          #$83:
          begin
            new_c1 := #$C6;
            new_c2 := #$80;
          end;
          #$84:
          begin
            new_c1 := #$CA;
            new_c2 := #$89;
          end;
          #$85:
          begin
            new_c1 := #$CA;
            new_c2 := #$8C;
          end;
          end;
        end;
        // $CE91..$CE9F: NewChar := OldChar + $20; // Greek Characters
        // $CEA0..$CEA9: NewChar := OldChar + $E0; // Greek Characters
        #$CE:
        begin
          case c2 of
            // 0380 = CE 80
            #$86: new_c2 := #$AC;
            #$88: new_c2 := #$AD;
            #$89: new_c2 := #$AE;
            #$8A: new_c2 := #$AF;
            #$8C: new_c1 := #$CF; // By coincidence new_c2 remains the same
            #$8E:
            begin
              new_c1 := #$CF;
              new_c2 := #$8D;
            end;
            #$8F:
            begin
              new_c1 := #$CF;
              new_c2 := #$8E;
            end;
            // 0390 = CE 90
            #$91..#$9F:
            begin
              new_c2 := chr(ord(c2) + $20);
            end;
            // 03A0 = CE A0
            #$A0..#$AB:
            begin
              new_c1 := #$CF;
              new_c2 := chr(ord(c2) - $20);
            end;
          end;
        end;
        // 03C0 = CF 80
        // 03D0 = CF 90
        // 03E0 = CF A0
        // 03F0 = CF B0
        #$CF:
        begin
          case c2 of
            // 03CF;GREEK CAPITAL KAI SYMBOL;Lu;0;L;;;;;N;;;;03D7; CF 8F => CF 97
            #$8F: new_c2 := #$97;
            // 03D8;GREEK LETTER ARCHAIC KOPPA;Lu;0;L;;;;;N;;;;03D9;
            #$98: new_c2 := #$99;
            // 03DA;GREEK LETTER STIGMA;Lu;0;L;;;;;N;GREEK CAPITAL LETTER STIGMA;;;03DB;
            #$9A: new_c2 := #$9B;
            // 03DC;GREEK LETTER DIGAMMA;Lu;0;L;;;;;N;GREEK CAPITAL LETTER DIGAMMA;;;03DD;
            #$9C: new_c2 := #$9D;
            // 03DE;GREEK LETTER KOPPA;Lu;0;L;;;;;N;GREEK CAPITAL LETTER KOPPA;;;03DF;
            #$9E: new_c2 := #$9F;
            {
            03E0;GREEK LETTER SAMPI;Lu;0;L;;;;;N;GREEK CAPITAL LETTER SAMPI;;;03E1;
            03E1;GREEK SMALL LETTER SAMPI;Ll;0;L;;;;;N;;;03E0;;03E0
            03E2;COPTIC CAPITAL LETTER SHEI;Lu;0;L;;;;;N;GREEK CAPITAL LETTER SHEI;;;03E3;
            03E3;COPTIC SMALL LETTER SHEI;Ll;0;L;;;;;N;GREEK SMALL LETTER SHEI;;03E2;;03E2
            ...
            03EE;COPTIC CAPITAL LETTER DEI;Lu;0;L;;;;;N;GREEK CAPITAL LETTER DEI;;;03EF;
            03EF;COPTIC SMALL LETTER DEI;Ll;0;L;;;;;N;GREEK SMALL LETTER DEI;;03EE;;03EE
            }
            #$A0..#$AF: if ord(c2) mod 2 = 0 then
                          new_c2 := chr(ord(c2) + 1);
            // 03F4;GREEK CAPITAL THETA SYMBOL;Lu;0;L;<compat> 0398;;;;N;;;;03B8;
            #$B4:
            begin
              new_c1 := #$CE;
              new_c2 := #$B8;
            end;
            // 03F7;GREEK CAPITAL LETTER SHO;Lu;0;L;;;;;N;;;;03F8;
            #$B7: new_c2 := #$B8;
            // 03F9;GREEK CAPITAL LUNATE SIGMA SYMBOL;Lu;0;L;<compat> 03A3;;;;N;;;;03F2;
            #$B9: new_c2 := #$B2;
            // 03FA;GREEK CAPITAL LETTER SAN;Lu;0;L;;;;;N;;;;03FB;
            #$BA: new_c2 := #$BB;
            // 03FD;GREEK CAPITAL REVERSED LUNATE SIGMA SYMBOL;Lu;0;L;;;;;N;;;;037B;
            #$BD:
            begin
              new_c1 := #$CD;
              new_c2 := #$BB;
            end;
            // 03FE;GREEK CAPITAL DOTTED LUNATE SIGMA SYMBOL;Lu;0;L;;;;;N;;;;037C;
            #$BE:
            begin
              new_c1 := #$CD;
              new_c2 := #$BC;
            end;
            // 03FF;GREEK CAPITAL REVERSED DOTTED LUNATE SIGMA SYMBOL;Lu;0;L;;;;;N;;;;037D;
            #$BF:
            begin
              new_c1 := #$CD;
              new_c2 := #$BD;
            end;
          end;
        end;
        // $D080..$D08F: NewChar := OldChar + $110; // Cyrillic alphabet
        // $D090..$D09F: NewChar := OldChar + $20; // Cyrillic alphabet
        // $D0A0..$D0AF: NewChar := OldChar + $E0; // Cyrillic alphabet
        #$D0:
        begin
          c2 := InStr[1];
          case c2 of
            #$80..#$8F:
            begin
              new_c1 := chr(ord(c1)+1);
              new_c2  := chr(ord(c2) + $10);
            end;
            #$90..#$9F:
            begin
              new_c2 := chr(ord(c2) + $20);
            end;
            #$A0..#$AF:
            begin
              new_c1 := chr(ord(c1)+1);
              new_c2 := chr(ord(c2) - $20);
            end;
          end;
        end;
        // Archaic and non-slavic cyrillic 460-47F = D1A0-D1BF
        // These require just adding 1 to get the lowercase
        #$D1:
        begin
          if (c2 in [#$A0..#$BF]) and (ord(c2) mod 2 = 0) then
            new_c2 := chr(ord(c2) + 1);
        end;
        // Archaic and non-slavic cyrillic 480-4BF = D280-D2BF
        // These mostly require just adding 1 to get the lowercase
        #$D2:
        begin
          case c2 of
            #$80:
            begin
              new_c2 := chr(ord(c2) + 1);
            end;
            // #$81 is already lowercase
            // #$82-#$89 ???
            #$8A..#$BF:
            begin
              if ord(c2) mod 2 = 0 then
                new_c2 := chr(ord(c2) + 1);
            end;
          end;
        end;
        {
        Codepoints  04C0..04FF
        }
        #$D3:
        begin
          case c2 of
            #$80: new_c2 := #$8F;
            #$81..#$8E:
            begin
              if ord(c2) mod 2 = 1 then
                new_c2 := chr(ord(c2) + 1);
            end;
            #$90..#$BF:
            begin
              if ord(c2) mod 2 = 0 then
                new_c2 := chr(ord(c2) + 1);
            end;
          end;
        end;
        {
        Codepoints  0500..053F

        Armenian starts in 0531
        }
        #$D4:
        begin
          if ord(c2) mod 2 = 0 then
            new_c2 := chr(ord(c2) + 1);

          // Armenian
          if c2 in [#$B1..#$BF] then
          begin
            new_c1 := #$D5;
            new_c2 := chr(ord(c2) - $10);
          end;
        end;
        {
        Codepoints  0540..057F

        Armenian
        }
        #$D5:
        begin
          case c2 of
            #$80..#$8F:
            begin
              new_c2 := chr(ord(c2) + $30);
            end;
            #$90..#$96:
            begin
              new_c1 := #$D6;
              new_c2 := chr(ord(c2) - $10);
            end;
          end;
        end;
        end;
        // Common code 2-byte modifiable chars
        if (CounterDiff <> 0) then
        begin
          OutStr^ := new_c1;
          OutStr[1] := new_c2;
        end
        else
        begin
          if (new_c1 <> c1) then OutStr^ := new_c1;
          if (new_c2 <> c2) then OutStr[1] := new_c2;
        end;
        inc(InStr, 2);
        inc(OutStr, 2);
      end;
      {
      Characters with 3 bytes
      }
      #$E1:
      begin
        new_c1 := c1;
        c2 := InStr[1];
        c3 := InStr[2];
        new_c2 := c2;
        new_c3 := c3;
        {
        Georgian codepoints 10A0-10C5 => 2D00-2D25

        In UTF-8 this is:
        E1 82 A0 - E1 82 BF => E2 B4 80 - E2 B4 9F
        E1 83 80 - E1 83 85 => E2 B4 A0 - E2 B4 A5
        }
        case c2 of
        #$82:
        if (c3 in [#$A0..#$BF]) then
        begin
          new_c1 := #$E2;
          new_c2 := #$B4;
          new_c3 := chr(ord(c3) - $20);
        end;
        #$83:
        if (c3 in [#$80..#$85]) then
        begin
          new_c1 := #$E2;
          new_c2 := #$B4;
          new_c3 := chr(ord(c3) + $20);
        end;
        {
        Extra chars between 1E00..1EFF

        Blocks of chars:
          1E00..1E3F    E1 B8 80..E1 B8 BF
          1E40..1E7F    E1 B9 80..E1 B9 BF
          1E80..1EBF    E1 BA 80..E1 BA BF
          1EC0..1EFF    E1 BB 80..E1 BB BF
        }
        #$B8..#$BB:
        begin
          // Start with a default and change for some particular chars
          if ord(c3) mod 2 = 0 then
            new_c3 := chr(ord(c3) + 1);

          { Only 1E96..1E9F are different E1 BA 96..E1 BA 9F

          1E96;LATIN SMALL LETTER H WITH LINE BELOW;Ll;0;L;0068 0331;;;;N;;;;;
          1E97;LATIN SMALL LETTER T WITH DIAERESIS;Ll;0;L;0074 0308;;;;N;;;;;
          1E98;LATIN SMALL LETTER W WITH RING ABOVE;Ll;0;L;0077 030A;;;;N;;;;;
          1E99;LATIN SMALL LETTER Y WITH RING ABOVE;Ll;0;L;0079 030A;;;;N;;;;;
          1E9A;LATIN SMALL LETTER A WITH RIGHT HALF RING;Ll;0;L;<compat> 0061 02BE;;;;N;;;;;
          1E9B;LATIN SMALL LETTER LONG S WITH DOT ABOVE;Ll;0;L;017F 0307;;;;N;;;1E60;;1E60
          1E9C;LATIN SMALL LETTER LONG S WITH DIAGONAL STROKE;Ll;0;L;;;;;N;;;;;
          1E9D;LATIN SMALL LETTER LONG S WITH HIGH STROKE;Ll;0;L;;;;;N;;;;;
          1E9E;LATIN CAPITAL LETTER SHARP S;Lu;0;L;;;;;N;;;;00DF; => C3 9F
          1E9F;LATIN SMALL LETTER DELTA;Ll;0;L;;;;;N;;;;;
          }
          if (c2 = #$BA) and (c3 in [#$96..#$9F]) then new_c3 := c3;
          // LATIN CAPITAL LETTER SHARP S => to german Beta
          if (c2 = #$BA) and (c3 = #$9E) then
          begin
            inc(InStr, 3);
            OutStr^ := #$C3;
            inc(OutStr);
            OutStr^ := #$9F;
            inc(OutStr);
            inc(CounterDiff, 1);
            Continue;
          end;
        end;
        {
        Extra chars between 1F00..1FFF

        Blocks of chars:
          1E00..1E3F    E1 BC 80..E1 BC BF
          1E40..1E7F    E1 BD 80..E1 BD BF
          1E80..1EBF    E1 BE 80..E1 BE BF
          1EC0..1EFF    E1 BF 80..E1 BF BF
        }
        #$BC:
        begin
          // Start with a default and change for some particular chars
          if (ord(c3) mod $10) div 8 = 1 then
            new_c3 := chr(ord(c3) - 8);
        end;
        #$BD:
        begin
          // Start with a default and change for some particular chars
          case c3 of
          #$80..#$8F, #$A0..#$AF: if (ord(c3) mod $10) div 8 = 1 then
                        new_c3 := chr(ord(c3) - 8);
          {
          1F50;GREEK SMALL LETTER UPSILON WITH PSILI;Ll;0;L;03C5 0313;;;;N;;;;;
          1F51;GREEK SMALL LETTER UPSILON WITH DASIA;Ll;0;L;03C5 0314;;;;N;;;1F59;;1F59
          1F52;GREEK SMALL LETTER UPSILON WITH PSILI AND VARIA;Ll;0;L;1F50 0300;;;;N;;;;;
          1F53;GREEK SMALL LETTER UPSILON WITH DASIA AND VARIA;Ll;0;L;1F51 0300;;;;N;;;1F5B;;1F5B
          1F54;GREEK SMALL LETTER UPSILON WITH PSILI AND OXIA;Ll;0;L;1F50 0301;;;;N;;;;;
          1F55;GREEK SMALL LETTER UPSILON WITH DASIA AND OXIA;Ll;0;L;1F51 0301;;;;N;;;1F5D;;1F5D
          1F56;GREEK SMALL LETTER UPSILON WITH PSILI AND PERISPOMENI;Ll;0;L;1F50 0342;;;;N;;;;;
          1F57;GREEK SMALL LETTER UPSILON WITH DASIA AND PERISPOMENI;Ll;0;L;1F51 0342;;;;N;;;1F5F;;1F5F
          1F59;GREEK CAPITAL LETTER UPSILON WITH DASIA;Lu;0;L;03A5 0314;;;;N;;;;1F51;
          1F5B;GREEK CAPITAL LETTER UPSILON WITH DASIA AND VARIA;Lu;0;L;1F59 0300;;;;N;;;;1F53;
          1F5D;GREEK CAPITAL LETTER UPSILON WITH DASIA AND OXIA;Lu;0;L;1F59 0301;;;;N;;;;1F55;
          1F5F;GREEK CAPITAL LETTER UPSILON WITH DASIA AND PERISPOMENI;Lu;0;L;1F59 0342;;;;N;;;;1F57;
          }
          #$99,#$9B,#$9D,#$9F: new_c3 := chr(ord(c3) - 8);
          end;
        end;
        #$BE:
        begin
          // Start with a default and change for some particular chars
          case c3 of
          #$80..#$B9: if (ord(c3) mod $10) div 8 = 1 then
                        new_c3 := chr(ord(c3) - 8);
          {
          1FB0;GREEK SMALL LETTER ALPHA WITH VRACHY;Ll;0;L;03B1 0306;;;;N;;;1FB8;;1FB8
          1FB1;GREEK SMALL LETTER ALPHA WITH MACRON;Ll;0;L;03B1 0304;;;;N;;;1FB9;;1FB9
          1FB2;GREEK SMALL LETTER ALPHA WITH VARIA AND YPOGEGRAMMENI;Ll;0;L;1F70 0345;;;;N;;;;;
          1FB3;GREEK SMALL LETTER ALPHA WITH YPOGEGRAMMENI;Ll;0;L;03B1 0345;;;;N;;;1FBC;;1FBC
          1FB4;GREEK SMALL LETTER ALPHA WITH OXIA AND YPOGEGRAMMENI;Ll;0;L;03AC 0345;;;;N;;;;;
          1FB6;GREEK SMALL LETTER ALPHA WITH PERISPOMENI;Ll;0;L;03B1 0342;;;;N;;;;;
          1FB7;GREEK SMALL LETTER ALPHA WITH PERISPOMENI AND YPOGEGRAMMENI;Ll;0;L;1FB6 0345;;;;N;;;;;
          1FB8;GREEK CAPITAL LETTER ALPHA WITH VRACHY;Lu;0;L;0391 0306;;;;N;;;;1FB0;
          1FB9;GREEK CAPITAL LETTER ALPHA WITH MACRON;Lu;0;L;0391 0304;;;;N;;;;1FB1;
          1FBA;GREEK CAPITAL LETTER ALPHA WITH VARIA;Lu;0;L;0391 0300;;;;N;;;;1F70;
          1FBB;GREEK CAPITAL LETTER ALPHA WITH OXIA;Lu;0;L;0386;;;;N;;;;1F71;
          1FBC;GREEK CAPITAL LETTER ALPHA WITH PROSGEGRAMMENI;Lt;0;L;0391 0345;;;;N;;;;1FB3;
          1FBD;GREEK KORONIS;Sk;0;ON;<compat> 0020 0313;;;;N;;;;;
          1FBE;GREEK PROSGEGRAMMENI;Ll;0;L;03B9;;;;N;;;0399;;0399
          1FBF;GREEK PSILI;Sk;0;ON;<compat> 0020 0313;;;;N;;;;;
          }
          #$BA:
          begin
            new_c2 := #$BD;
            new_c3 := #$B0;
          end;
          #$BB:
          begin
            new_c2 := #$BD;
            new_c3 := #$B1;
          end;
          #$BC: new_c3 := #$B3;
          end;
        end;
        end;

        if (CounterDiff <> 0) then
        begin
          OutStr^ := new_c1;
          OutStr[1] := new_c2;
          OutStr[2] := new_c3;
        end
        else
        begin
          if c1 <> new_c1 then OutStr^ := new_c1;
          if c2 <> new_c2 then OutStr[1] := new_c2;
          if c3 <> new_c3 then OutStr[2] := new_c3;
        end;

        inc(InStr, 3);
        inc(OutStr, 3);
      end;
      {
      More Characters with 3 bytes, so exotic stuff between:
      $2126..$2183                    E2 84 A6..E2 86 83
      $24B6..$24CF    Result:=u+26;   E2 92 B6..E2 93 8F
      $2C00..$2C2E    Result:=u+48;   E2 B0 80..E2 B0 AE
      $2C60..$2CE2                    E2 B1 A0..E2 B3 A2
      }
      #$E2:
      begin
        new_c1 := c1;
        c2 := InStr[1];
        c3 := InStr[2];
        new_c2 := c2;
        new_c3 := c3;
        // 2126;OHM SIGN;Lu;0;L;03A9;;;;N;OHM;;;03C9; E2 84 A6 => CF 89
        if (c2 = #$84) and (c3 = #$A6) then
        begin
          inc(InStr, 3);
          OutStr^ := #$CF;
          inc(OutStr);
          OutStr^ := #$89;
          inc(OutStr);
          inc(CounterDiff, 1);
          Continue;
        end
        {
        212A;KELVIN SIGN;Lu;0;L;004B;;;;N;DEGREES KELVIN;;;006B; E2 84 AA => 6B
        }
        else if (c2 = #$84) and (c3 = #$AA) then
        begin
          inc(InStr, 3);
          if c3 = #$AA then OutStr^ := #$6B
          else OutStr^ := #$E5;
          inc(OutStr);
          inc(CounterDiff, 2);
          Continue;
        end
        {
        212B;ANGSTROM SIGN;Lu;0;L;00C5;;;;N;ANGSTROM UNIT;;;00E5; E2 84 AB => C3 A5
        }
        else if (c2 = #$84) and (c3 = #$AB) then
        begin
          inc(InStr, 3);
          OutStr^ := #$C3;
          inc(OutStr);
          OutStr^ := #$A5;
          inc(OutStr);
          inc(CounterDiff, 1);
          Continue;
        end
        {
        2160;ROMAN NUMERAL ONE;Nl;0;L;<compat> 0049;;;1;N;;;;2170; E2 85 A0 => E2 85 B0
        2161;ROMAN NUMERAL TWO;Nl;0;L;<compat> 0049 0049;;;2;N;;;;2171;
        2162;ROMAN NUMERAL THREE;Nl;0;L;<compat> 0049 0049 0049;;;3;N;;;;2172;
        2163;ROMAN NUMERAL FOUR;Nl;0;L;<compat> 0049 0056;;;4;N;;;;2173;
        2164;ROMAN NUMERAL FIVE;Nl;0;L;<compat> 0056;;;5;N;;;;2174;
        2165;ROMAN NUMERAL SIX;Nl;0;L;<compat> 0056 0049;;;6;N;;;;2175;
        2166;ROMAN NUMERAL SEVEN;Nl;0;L;<compat> 0056 0049 0049;;;7;N;;;;2176;
        2167;ROMAN NUMERAL EIGHT;Nl;0;L;<compat> 0056 0049 0049 0049;;;8;N;;;;2177;
        2168;ROMAN NUMERAL NINE;Nl;0;L;<compat> 0049 0058;;;9;N;;;;2178;
        2169;ROMAN NUMERAL TEN;Nl;0;L;<compat> 0058;;;10;N;;;;2179;
        216A;ROMAN NUMERAL ELEVEN;Nl;0;L;<compat> 0058 0049;;;11;N;;;;217A;
        216B;ROMAN NUMERAL TWELVE;Nl;0;L;<compat> 0058 0049 0049;;;12;N;;;;217B;
        216C;ROMAN NUMERAL FIFTY;Nl;0;L;<compat> 004C;;;50;N;;;;217C;
        216D;ROMAN NUMERAL ONE HUNDRED;Nl;0;L;<compat> 0043;;;100;N;;;;217D;
        216E;ROMAN NUMERAL FIVE HUNDRED;Nl;0;L;<compat> 0044;;;500;N;;;;217E;
        216F;ROMAN NUMERAL ONE THOUSAND;Nl;0;L;<compat> 004D;;;1000;N;;;;217F;
        }
        else if (c2 = #$85) and (c3 in [#$A0..#$AF]) then new_c3 := chr(ord(c3) + $10)
        {
        2183;ROMAN NUMERAL REVERSED ONE HUNDRED;Lu;0;L;;;;;N;;;;2184; E2 86 83 => E2 86 84
        }
        else if (c2 = #$86) and (c3 = #$83) then new_c3 := chr(ord(c3) + 1)
        {
        $24B6..$24CF    Result:=u+26;   E2 92 B6..E2 93 8F

        Ex: 24B6;CIRCLED LATIN CAPITAL LETTER A;So;0;L;<circle> 0041;;;;N;;;;24D0; E2 92 B6 => E2 93 90
        }
        else if (c2 = #$92) and (c3 in [#$B6..#$BF]) then
        begin
          new_c3 := #$93;
          new_c3 := chr(ord(c3) - $26);
        end
        else if (c2 = #$93) and (c3 in [#$80..#$8F]) then new_c3 := chr(ord(c3) + 26)
        {
        $2C00..$2C2E    Result:=u+48;   E2 B0 80..E2 B0 AE

        2C00;GLAGOLITIC CAPITAL LETTER AZU;Lu;0;L;;;;;N;;;;2C30; E2 B0 80 => E2 B0 B0

        2C10;GLAGOLITIC CAPITAL LETTER NASHI;Lu;0;L;;;;;N;;;;2C40; E2 B0 90 => E2 B1 80
        }
        else if (c2 = #$B0) and (c3 in [#$80..#$8F]) then new_c3 := chr(ord(c3) + $30)
        else if (c2 = #$B0) and (c3 in [#$90..#$AE]) then
        begin
          new_c2 := #$B1;
          new_c3 := chr(ord(c3) - $10);
        end
        {
        $2C60..$2CE2                    E2 B1 A0..E2 B3 A2

        2C60;LATIN CAPITAL LETTER L WITH DOUBLE BAR;Lu;0;L;;;;;N;;;;2C61; E2 B1 A0 => +1
        2C61;LATIN SMALL LETTER L WITH DOUBLE BAR;Ll;0;L;;;;;N;;;2C60;;2C60
        2C62;LATIN CAPITAL LETTER L WITH MIDDLE TILDE;Lu;0;L;;;;;N;;;;026B; => 	C9 AB
        2C63;LATIN CAPITAL LETTER P WITH STROKE;Lu;0;L;;;;;N;;;;1D7D; => E1 B5 BD
        2C64;LATIN CAPITAL LETTER R WITH TAIL;Lu;0;L;;;;;N;;;;027D; => 	C9 BD
        2C65;LATIN SMALL LETTER A WITH STROKE;Ll;0;L;;;;;N;;;023A;;023A
        2C66;LATIN SMALL LETTER T WITH DIAGONAL STROKE;Ll;0;L;;;;;N;;;023E;;023E
        2C67;LATIN CAPITAL LETTER H WITH DESCENDER;Lu;0;L;;;;;N;;;;2C68; => E2 B1 A8
        2C68;LATIN SMALL LETTER H WITH DESCENDER;Ll;0;L;;;;;N;;;2C67;;2C67
        2C69;LATIN CAPITAL LETTER K WITH DESCENDER;Lu;0;L;;;;;N;;;;2C6A; => E2 B1 AA
        2C6A;LATIN SMALL LETTER K WITH DESCENDER;Ll;0;L;;;;;N;;;2C69;;2C69
        2C6B;LATIN CAPITAL LETTER Z WITH DESCENDER;Lu;0;L;;;;;N;;;;2C6C; => E2 B1 AC
        2C6C;LATIN SMALL LETTER Z WITH DESCENDER;Ll;0;L;;;;;N;;;2C6B;;2C6B
        2C6D;LATIN CAPITAL LETTER ALPHA;Lu;0;L;;;;;N;;;;0251; => C9 91
        2C6E;LATIN CAPITAL LETTER M WITH HOOK;Lu;0;L;;;;;N;;;;0271; => C9 B1
        2C6F;LATIN CAPITAL LETTER TURNED A;Lu;0;L;;;;;N;;;;0250; => C9 90

        2C70;LATIN CAPITAL LETTER TURNED ALPHA;Lu;0;L;;;;;N;;;;0252; => C9 92
        }
        else if (c2 = #$B1) then
        begin
          case c3 of
          #$A0: new_c3 := chr(ord(c3)+1);
          #$A2,#$A4,#$AD..#$AF,#$B0:
          begin
            inc(InStr, 3);
            OutStr^ := #$C9;
            inc(OutStr);
            case c3 of
            #$A2: OutStr^ := #$AB;
            #$A4: OutStr^ := #$BD;
            #$AD: OutStr^ := #$91;
            #$AE: OutStr^ := #$B1;
            #$AF: OutStr^ := #$90;
            #$B0: OutStr^ := #$92;
            end;
            inc(OutStr);
            inc(CounterDiff, 1);
            Continue;
          end;
          #$A3:
          begin
            new_c2 := #$B5;
            new_c3 := #$BD;
          end;
          #$A7,#$A9,#$AB: new_c3 := chr(ord(c3)+1);
          {
          2C71;LATIN SMALL LETTER V WITH RIGHT HOOK;Ll;0;L;;;;;N;;;;;
          2C72;LATIN CAPITAL LETTER W WITH HOOK;Lu;0;L;;;;;N;;;;2C73;
          2C73;LATIN SMALL LETTER W WITH HOOK;Ll;0;L;;;;;N;;;2C72;;2C72
          2C74;LATIN SMALL LETTER V WITH CURL;Ll;0;L;;;;;N;;;;;
          2C75;LATIN CAPITAL LETTER HALF H;Lu;0;L;;;;;N;;;;2C76;
          2C76;LATIN SMALL LETTER HALF H;Ll;0;L;;;;;N;;;2C75;;2C75
          2C77;LATIN SMALL LETTER TAILLESS PHI;Ll;0;L;;;;;N;;;;;
          2C78;LATIN SMALL LETTER E WITH NOTCH;Ll;0;L;;;;;N;;;;;
          2C79;LATIN SMALL LETTER TURNED R WITH TAIL;Ll;0;L;;;;;N;;;;;
          2C7A;LATIN SMALL LETTER O WITH LOW RING INSIDE;Ll;0;L;;;;;N;;;;;
          2C7B;LATIN LETTER SMALL CAPITAL TURNED E;Ll;0;L;;;;;N;;;;;
          2C7C;LATIN SUBSCRIPT SMALL LETTER J;Ll;0;L;<sub> 006A;;;;N;;;;;
          2C7D;MODIFIER LETTER CAPITAL V;Lm;0;L;<super> 0056;;;;N;;;;;
          2C7E;LATIN CAPITAL LETTER S WITH SWASH TAIL;Lu;0;L;;;;;N;;;;023F; => C8 BF
          2C7F;LATIN CAPITAL LETTER Z WITH SWASH TAIL;Lu;0;L;;;;;N;;;;0240; => C9 80
          }
          #$B2,#$B5: new_c3 := chr(ord(c3)+1);
          #$BE,#$BF:
          begin
            inc(InStr, 3);
            case c3 of
            #$BE: OutStr^ := #$C8;
            #$BF: OutStr^ := #$C9;
            end;
            OutStr^ := #$C8;
            inc(OutStr);
            case c3 of
            #$BE: OutStr^ := #$BF;
            #$BF: OutStr^ := #$80;
            end;
            inc(OutStr);
            inc(CounterDiff, 1);
            Continue;
          end;
          end;
        end
        {
        2C80;COPTIC CAPITAL LETTER ALFA;Lu;0;L;;;;;N;;;;2C81; E2 B2 80 => E2 B2 81
        ...
        2CBE;COPTIC CAPITAL LETTER OLD COPTIC OOU;Lu;0;L;;;;;N;;;;2CBF; E2 B2 BE => E2 B2 BF
        2CBF;COPTIC SMALL LETTER OLD COPTIC OOU;Ll;0;L;;;;;N;;;2CBE;;2CBE
        ...
        2CC0;COPTIC CAPITAL LETTER SAMPI;Lu;0;L;;;;;N;;;;2CC1; E2 B3 80 => E2 B2 81
        2CC1;COPTIC SMALL LETTER SAMPI;Ll;0;L;;;;;N;;;2CC0;;2CC0
        ...
        2CE2;COPTIC CAPITAL LETTER OLD NUBIAN WAU;Lu;0;L;;;;;N;;;;2CE3; E2 B3 A2 => E2 B3 A3
        2CE3;COPTIC SMALL LETTER OLD NUBIAN WAU;Ll;0;L;;;;;N;;;2CE2;;2CE2 <=
        }
        else if (c2 = #$B2) then
        begin
          if ord(c3) mod 2 = 0 then new_c3 := chr(ord(c3) + 1);
        end
        else if (c2 = #$B3) and (c3 in [#$80..#$A3]) then
        begin
          if ord(c3) mod 2 = 0 then new_c3 := chr(ord(c3) + 1);
        end;

        if (CounterDiff <> 0) then
        begin
          OutStr^ := new_c1;
          OutStr[1] := new_c2;
          OutStr[2] := new_c3;
        end
        else
        begin
          if c1 <> new_c1 then OutStr^ := new_c1;
          if c2 <> new_c2 then OutStr[1] := new_c2;
          if c3 <> new_c3 then OutStr[2] := new_c3;
        end;

        inc(InStr, 3);
        inc(OutStr, 3);
      end;
      {
      FF21;FULLWIDTH LATIN CAPITAL LETTER A;Lu;0;L;<wide> 0041;;;;N;;;;FF41; EF BC A1 => EF BD 81
      ...
      FF3A;FULLWIDTH LATIN CAPITAL LETTER Z;Lu;0;L;<wide> 005A;;;;N;;;;FF5A; EF BC BA => EF BD 9A
      }
      #$EF:
      begin
        c2 := InStr[1];
        c3 := InStr[2];

        if (c2 = #$BC) and (c3 in [#$A1..#$BA]) then
        begin
          OutStr^ := c1;
          OutStr[1] := #$BD;
          OutStr[2] := chr(ord(c3) - $20);
        end;

        if (CounterDiff <> 0) then
        begin
          OutStr^ := c1;
          OutStr[1] := c2;
          OutStr[2] := c3;
        end;

        inc(InStr, 3);
        inc(OutStr, 3);
      end;
    else
      // Copy the character if the string was disaligned by previous changes
      if (CounterDiff <> 0) then OutStr^:= c1;
      inc(InStr);
      inc(OutStr);
    end; // Case InStr^
  end; // while

  // Final correction of the buffer size
  SetLength(Result,OutStr - PChar(Result));
end;
//--------------------------------lasUTF8 copy end



function bytesToBIP39(buf:ansistring;const bipArray:array of string;separator:string=' '):string;
var i:integer;
begin
  result:='';
  for i:=1 to (length(buf)*8) div 11 do begin
    result:=bipArray[ord(buf[length(buf)]) + $100*(ord(buf[length(buf)-1]) and 7)]+separator+result;
    buf:=shrbuf(buf,11);
  end;
  //result:=trim(result);
  delete(result,length(result)-length(separator)+1,length(separator));
end;


function checkEntropy(buf:ansistring):boolean;
var c:integer; //c- crc bits count
    crc:byte;
    s:ansistring;
begin
  result:=false;
  if length(buf)<5 then exit;

  c:= (length(buf)*8) div 33;
  crc:=ord(buf[length(buf)]) and ((1 shl c) -1);

  buf:= shrbuf(buf,c);

  //delete first byte?
 //         __unused bits count__
  if (  (8-(length(buf)*8) mod 11)  )<=c then delete(buf,1,1);

  s:=dosha256(buf);
  //result:= (ord(s[length(s)]) and (1 shl c -1)) = crc;
  result:= (ord(s[1]) shr (8 - c) ) = crc;
end;


{tRndGen}
constructor tRndGen.create();
begin
  Randomize();
  frndCallCount:=1;
  frnSeed:=Random($FFFFFFFF {FFFFFFFF});

end;

procedure tRndGen.doRandomize(x:dWord);
var n:dWord;
begin
  Randomize();
  n:=Random($FFFFFFFF{FFFFFFFF});

  frnSeed:=frnSeed xor n;

  while x>0 do begin
    n:=Random($FFFFFFFF{FFFFFFFF});
    //n:=n rol (x mod 64);
    n:=(n shl (x mod 64)) or (n shr (64-x mod 64));
    x:=x div 64;
    frnSeed:=frnSeed xor n;
  end;
  inc(frndCallCount);
end;

function tRndGen.getRandom(n:dWord):dWord;
begin
  result:=Random($FFFFFFFF{FFFFFFFF});
  result:=result xor frnSeed;
  result:=result mod n;
end;

function tRndGen.isReady:boolean;
begin
  result:= frndCallCount > 10;
end;

{/tRndGen}

function makeCharRandomPassword(d:double;charstring:ansistring):ansistring; //log10 rate
var sCount:integer;
    i:integer;
begin
  //random generator must me ready

  result:='';
  if not RndGen.rndReady then raise exception.Create('RND is not ready');

  //symbol count = frac(min dif) + 1 =
  //rate 1= log10(10) = 3.(3) bits.
  // we have length(charstring), so , it's log10(length(charstring)) points for one char
  // d points => d/log10(length(charstring)) chars
  sCount:=1 + trunc(d/log10(length(charstring)));
  for i:=1 to sCount do
     result:=result +charstring[1+RndGen.getRandom(length(charstring))] ;
end;


function normalizeBip(bip:string):string;
var bytes:ansistring;
begin
  result:='';
  bytes:=bip39tobytes(bip,bip0039english,' ');
  if bytes<>'' then begin
     result:=bytesToBIP39(bytes,bip0039english);
     exit;
  end;
  bytes:=bip39tobytes(bip,bip0039chinese,'');
  if bytes<>'' then begin
     result:=bytesToBIP39(bytes,bip0039chinese,'');
     exit;
  end;

end;

function bip39tobytes(bip:string):ansistring;
begin
  result:=bip39tobytes(bip,bip0039english,' ');
  if result='' then
     result:=bip39tobytes(bip,bip0039chinese,'');
end;

function bip39tobytes(bip:string;const bipArray:array of string;divider:string=''):ansistring;
Var
  //bn:PBIGNUM;
  //badd:PBIGNUM;
  //bmul:PBIGNUM;
  //ctx : PBN_CTX;
  bn:tBigInteger;
  //badd:tBigInteger;
  bmul:tBigInteger;
var
  {w,}t:ansistring;
  i,n,m:integer;
  ba:arrayofString;
begin
  Result := '';
  if length(trim(bip))=0 then exit;

  //split bip by divider
  if divider=''
    then ba:=UTF8toAnsiCharArray(bip)
    else ba:=splitString(bip,divider);

  //cut words and add it by 11 bits


    //t:=#11;   2048 надо =
    bmul:=buf2tBigInteger(#8#0);  //BN_bin2bn(PAnsiChar(t),1,bmul);
    bn:=tBigInteger.Zero;

    for i:=0 to length(ba)-1 do if ba[i]<>'' then begin
      n:=0;
      while (n<length(bipArray)) and (bipArray[n]<>ba[i]) do inc(n);
      if n<length(bipArray) then begin
        //if BN_mul(bn, bn, bmul, ctx)<>1 then raise exception.Create('bip39tobytes: can''t calc x=x*11');
        bn:=bn.Multiply(bmul);

        t:=chr(n div $100) + chr(n mod $100);
        //badd:=buf2tBigInteger(t);  //BN_bin2bn(PAnsiChar(t),2,badd);
        //if BN_add(bn,bn,badd)<>1 then raise exception.Create('bip39tobytes: can''t calc x=x+a');
        bn:=bn.Add(buf2tBigInteger(t));

      end else exit; // not bip0039
    end;


    result:=tBigInteger2buf(bn);
    while length(result)<(((length(ba)*11 -1)) div 8 + 1) do
      result:=#0+result;
{  ;-/   BN_num_bytes(bn);
    SetLength(Result,max(i,(length(ba)*11 -1)) div 8 + 1);
    fillchar(result[1],length(result),0);
    i := BN_bn2bin(bn,@Result[1]);
  }
end;

//https://github.com/emcsec/emcsec-android/blob/master/src/app/src/main/java/com/aspanta/emcsec/tools/MnemonicCodeCustom.java#L112


function BitstoEntropy(bits:ansistring):ansistring;
var b:byte;
    concatLenBits,checksumLengthBits,entropyLengthBits:integer;
    ii,jj,i:integer;
    hash:ansistring;
begin
  //must be n*3*11 bits
  result:='';
  if length(bits)<5 then exit;
  if (length(bits)*8) mod 33 > 7 then exit;//wrong length

  //check leading zeros:
  b:=ord(bits[1]);
  b:=b shr ((length(bits)*8) mod 11);
  if b>0 then exit;

  concatLenBits:=11*((length(bits)*8) div 11);

  //int checksumLengthBits = concatLenBits / 33;
  //int entropyLengthBits = concatLenBits - checksumLengthBits;
  checksumLengthBits := concatLenBits div 33;
  entropyLengthBits := concatLenBits - checksumLengthBits;


  // Extract original entropy as bytes.
  //byte[] entropy = new byte[entropyLengthBits / 8];
  //for (int ii = 0; ii < entropy.length; ++ii)
  //    for (int jj = 0; jj < 8; ++jj)
  //        if (concatBits[(ii * 8) + jj])
  //            entropy[ii] |= 1 << (7 - jj);
  setLength(result,entropyLengthBits div 8);
  fillchar(result[1],length(result),0);
  for ii:=0 to length(result)-1 do
     for jj:=0 to 7 do
        if (ord(bits[ii+1]) and (1 shl jj))>0 then
           result[ii+1]:=chr(ord(result[ii+1]) or (1 shl (7-jj)));


  // Take the digest of the entropy.
  //byte[] hash = Sha256Hash.hash(entropy);
  //boolean[] hashBits = bytesToBits(hash);
  hash:=dosha256(result);

  // Check all the checksum bits.
  //for (int i = 0; i < checksumLengthBits; ++i)
  //    if (concatBits[entropyLengthBits + i] != hashBits[i])
  //        throw new MnemonicException.MnemonicChecksumException();
  for i:=0 to checksumLengthBits-1 do
    if ((ord(bits[1+(entropyLengthBits + i) div 8]) and (1 shl ((entropyLengthBits + i) mod 8)))>0)
       xor
       ((ord(hash[1 + i div 8]) and (1 shl (i mod 8)))>0)
      then begin
        result:='';
        exit;
      end;

  //return entropy;

end;

function getBip39FromMasterPassword(buf:ansistring):string;
var
  hash,res:ansistring;
  crc:byte;
  i:integer;
begin
  //create entropy 128 bit
  buf:=copy(dosha256(buf),1,16);

  hash:=dosha256(buf);
  //err crc:=ord(hash[length(hash)]);
  //err crc:=crc and (1 shl (length(buf) div 4) - 1);
  crc:=ord(hash[1]) shr (8 - length(buf) div 4);

  //shl buf for length(buf) div 4
  res:=shlbuf(buf,length(buf) div 4);

  res[length(res)]:=chr(ord(res[length(res)]) + crc);

  result:=bytesToBIP39(res,bip0039english,' ');
end;

function smartExtractBIP32pass(pass:string):ansistring;
var s:ansistring;st:string;
begin
  //if pass is a BIP39 12 words sequence => it is just entropy with a checksum, bip39 encoded
  //overwise copy(dosha256(pass),1,16) is the entropy w/o checksum
  result:='';
  s:='';

  s:=bip39tobytes(pass);
  if length(s)=17 then
     //normal bip
     result:=normalizeBip(pass)
  else
     result:=getBip39FromMasterPassword(pass);


end;

function bip39toEntropy(bip39:string):ansistring;
begin
  result:=BitstoEntropy(bip39tobytes(bip39));
end;

function bipWordstoEntropy(words: array of word):ansistring;
var concatLenBits:integer;
begin
  result:='';
  if length(words) mod 3 >0 then exit;
  if length(words) = 0 then exit;
  (*
        // Look up all the words in the list and construct the
        // concatenation of the original entropy and the checksum.
        //
  concatLenBits := words.size() * 11;
//       boolean[] concatBits = new boolean[concatLenBits];
  setLength(concatBits,concatLenBits)
        int wordindex = 0;
        for (String word : words) {
            // Find the words index in the wordlist.
            int ndx = Collections.binarySearch(this.wordList, word);
            if (ndx < 0)
                throw new MnemonicException.MnemonicWordException(word);

            // Set the next 11 bits to the value of the index.
            for (int ii = 0; ii < 11; ++ii)
                concatBits[(wordindex * 11) + ii] = (ndx & (1 << (10 - ii))) != 0;
            ++wordindex;
        }

        int checksumLengthBits = concatLenBits / 33;
        int entropyLengthBits = concatLenBits - checksumLengthBits;

        // Extract original entropy as bytes.
        byte[] entropy = new byte[entropyLengthBits / 8];
        for (int ii = 0; ii < entropy.length; ++ii)
            for (int jj = 0; jj < 8; ++jj)
                if (concatBits[(ii * 8) + jj])
                    entropy[ii] |= 1 << (7 - jj);

        // Take the digest of the entropy.
        byte[] hash = Sha256Hash.hash(entropy);
        boolean[] hashBits = bytesToBits(hash);

        // Check all the checksum bits.
        for (int i = 0; i < checksumLengthBits; ++i)
            if (concatBits[entropyLengthBits + i] != hashBits[i])
                throw new MnemonicException.MnemonicChecksumException();

        return entropy;
 *)
end;




function createBIP32seed(recovery:string;pass:string='witnesskey';iterCount:integer=2048):ansistring; //64 bytes
var bytes:ansistring;
var
  Password, Salt, Key: TBytes;
  Hash: IHash;

  //const
  //PBKDF2_ROUNDS=4096;
begin
  //check if it is bip
  //result:=bip39tobytes(bip,bip0039english,' ');
  //if result='' then
  //   result:=bip39tobytes(bip,bip0039chinese,'');

  // To create binary seed from mnemonic, we use PBKDF2 function
  // with mnemonic sentence (in UTF-8) used as a password and
  // string "mnemonic" + passphrase (again in UTF-8) used as a
  // salt. Iteration countEmc is set to 4096 and HMAC-SHA512 is
  // used as a pseudo-random function. Desired length of the
  // derived key is 512 bits (= 64 bytes).
  //

  //while pos(' ',recovery)>0 do delete(recovery,pos(' ',recovery),1);
  Password := buf2bytes(recovery);//TConverters.ConvertStringToBytes('password', TEncoding.UTF8);
  Salt := buf2bytes(pass);//TConverters.ConvertStringToBytes('salt', TEncoding.UTF8);
  Hash := THashFactory.TCrypto.CreateSHA2_512();

  result := bytes2buf(TKDF.TPBKDF2_HMAC.CreatePBKDF2_HMAC(Hash, Password, Salt, iterCount).GetBytes(64));


end;

function createBinaryBIP32seed(recovery:ansistring;pbipArray:pointer=nil;pass:ansistring='witnesskey'):ansistring; //64 bytes
type
 tarr=array [0..2047] of string;
var
  Password, Salt, Key: TBytes;
  Hash: IHash;
  parr:^tarr;
const
  PBKDF2_ROUNDS=4096;
  //BIP32SALT:string='witnesskey';

begin
  if pbipArray<>nil
     then parr:=pbipArray
     else parr:=@bip0039english;

  //public static byte[] toSeed(List<String> words, String passphrase)
  {

      // To create binary seed from mnemonic, we use PBKDF2 function
      // with mnemonic sentence (in UTF-8) used as a password and
      // string "mnemonic" + passphrase (again in UTF-8) used as a
      // salt. Iteration countEmc is set to 4096 and HMAC-SHA512 is
      // used as a pseudo-random function. Desired length of the
      // derived key is 512 bits (= 64 bytes).
      //

      String pass = Utils.join(words);
      String salt = "witnesskey" + passphrase;

      final Stopwatch watch = Stopwatch.createStarted();
      byte[] seed = PBKDF2SHA512.derive(pass, salt, PBKDF2_ROUNDS, 64);
      watch.stop();
      log.info("PBKDF2 took {}", watch);
      return seed;
  }



  Password := buf2bytes(recovery);//TConverters.ConvertStringToBytes('password', TEncoding.UTF8);
  Salt := buf2bytes(pass);//TConverters.ConvertStringToBytes('salt', TEncoding.UTF8);
  Hash := THashFactory.TCrypto.CreateSHA2_512();

  result := bytes2buf(TKDF.TPBKDF2_HMAC.CreatePBKDF2_HMAC(Hash, Password, Salt, PBKDF2_ROUNDS).GetBytes(64));
 {
  result:=recovery;
  for i:=0 to 99999 do
     result:=hmac




     TPBKDF2_HMAC = class sealed(TObject)

     public

       /// <summary>
       /// Initializes a new interface instance of the TPBKDF2_HMAC class using a password, a salt, a number of iterations and an Instance of an "IHash" to be used as an "IHMAC" hashing implementation to derive the key.
       /// </summary>
       /// <param name="a_hash">The name of the "IHash" implementation to be transformed to an "IHMAC" Instance so it can be used to derive the key.</param>
       /// <param name="password">The password to derive the key for.</param>
       /// <param name="salt">The salt to use to derive the key.</param>
       /// <param name="iterations">The number of iterations to use to derive the key.</param>
       /// <exception cref="EArgumentNilHashLibException">The password, salt or algorithm is Nil.</exception>
       /// <exception cref="EArgumentHashLibException">The iteration is less than 1.</exception>

       class function CreatePBKDF2_HMAC(const a_hash: IHash;
         const a_password, a_salt: THashLibByteArray; a_iterations: UInt32)
         : IPBKDF2_HMAC; static;

     var
       Password, Salt, Key: TBytes;
       Hash: IHash;

     begin
       FExpectedString :=
         '0394A2EDE332C9A13EB82E9B24631604C31DF978B4E2F0FBD2C549944F9D79A5';
       Password := TConverters.ConvertStringToBytes('password', TEncoding.UTF8);
       Salt := TConverters.ConvertStringToBytes('salt', TEncoding.UTF8);
       Hash := THashFactory.TCrypto.CreateSHA2_256();
       Key := TKDF.TPBKDF2_HMAC.CreatePBKDF2_HMAC(Hash, Password, Salt, 100000)
         .GetBytes(32);
         }

end;

function decodePassword(pwd:string;decodeBIP39Asbits:boolean=true):ansistring;
var s:ansiString;
begin

 //1 byte : 0xxxxxxx
 //2 bytes : 110xxxxx 10xxxxxx
 //3 bytes : 1110xxxx 10xxxxxx 10xxxxxx
 //4 bytes : 11110xxx 10xxxxxx 10xxxxxx 10xxxxxx
 result:=pwd;
 if decodeBIP39Asbits then begin
   s:=bip39tobytes(result);
   if s<>'' then result:=s;
 end;
end;

function makeBIP39RandomPassword(d:double;const bipArray:array of string;divider:string=' '):ansistring; //log10 rate
var wordCount:integer;
    i:integer;
begin
  //random generator must me ready

  result:='';
  if not RndGen.rndReady then raise exception.Create('RND is not ready');

  //word count = frac(min dif) + 1 =
  //rate 1= log10(10) = 3.(3) bits.
  // BIP39 has 11 bit per word => 1 word has log10rate = 11/3.(3)
  // we need d*10/3 bits; so, we need (d*10/3)/11 bip39 words =
  wordCount:=1 + trunc(d*10/33);
  for i:=1 to wordCount do
     result:=result +bipArray[RndGen.getRandom(2048)] + divider;
  if (length(result)>0) and (divider<>'') then
     delete(result,length(result)-length(divider)+1,length(divider));
end;

function splitString(s,divider: String;ignoreEmpty:boolean=true):arrayOfString;
var i,n:integer;
begin
  setLength(result,length(s));
  if trim(s)='' then exit;

  s:=s+divider;
  i:=0;
  n:=pos(divider,s);
  while n>0 do begin
    if (n>1) or (not ignoreEmpty) then begin
      result[i]:=copy(s,1,n-1);
      inc(i);
    end;
    delete(s,1,n+length(divider)-1);
    n:=pos(divider,s);
  end;
  setLength(result,i)
end;

function UTF8toAnsiCharArray(S: String):arrayOfString;
var
  CurP, EndP: PChar;
  Len: Integer;
  //ACodePoint: String;
  ctr:integer;
begin
  setlength(result,length(s));
  CurP := PChar(S);        // if S='' then PChar(S) returns a pointer to #0
  EndP := CurP + length(S);
  ctr:=0;
  while CurP < EndP do
  begin
    Len := UTF8CharacterLength(CurP);
    SetLength(result[ctr], Len);
    Move(CurP^, result[ctr][1], Len);
    // A single codepoint is copied from the string. Do your thing with it.
    //ShowMessageFmt('CodePoint=%s, Len=%d', [ACodePoint, Len]);
    // ...

    inc(ctr);
    inc(CurP, Len);
  end;
  setlength(result,ctr);
end;


//function ratePasswordUnicode(password:string):double; //log10 rate
//var
//  i:integer;
//  c:char;
//begin
 // result:=ratePassword(decodePassword(password,false));
//end;

function SymbolCount(s:string):integer;
begin
  result:=UTF8Length(s);
end;

function calcRate(base,len:integer):double;
var m:double;
begin
  // result:=log10(power(base,len)) = len +  log10(power(base/10,len))

  //result = m*len + log10(power(b/exp(10,m),len))  : m - any

  // we need base/power(10,m) ->1   => m -> log10(b) => r = len*log10(b)+log(1)

//  if len>100 then m:=len/100 else m:=1;
//  result := m*len + log10(power(base/power(10,m),len)); //m=2

  result := len*log10(base) + log10(1);

end;

function getLangByChar(s:string):string;
var uc : Cardinal;
    CharLen:integer;
begin

  result:='';

  uc := UTF8CharacterToUnicode(PChar(s), CharLen);
  if uc=0 then exit;


  //https://en.wikipedia.org/wiki/Unicode_block
       if uc<128 then result:='en'
  //'cjk': unicode areas main : 4E00-62FF, 6300-77FF, 7800-8CFF, 8D00-9FFF :main set, let's call it cjk
  else if (($4E00<=uc)and(uc<=$62FF)) or (($6300<=uc)and(uc<=$77FF))  or (($7800<=uc)and(uc<=$8CFF))  or (($8D00<=uc)and(uc<=$9FFF)) then result:='cjk'
  //'cjka' ext a:  3400-4DBF
  else if (($3400<=uc)and(uc<=$4DBF)) then result:='cjka'
  //'cjkb' ext b: 20000-215FF, 21600-230FF, 23100-245FF, 24600-260FF, 26100-275FF, 27600-290FF, 29100-2A6DF. Kangxi Dictionary , formerly used to write Vietnamese. Not used now
  else if (($20000<=uc)and(uc<=$215FF))or(($21600<=uc)and(uc<=$230FF))or(($23100<=uc)and(uc<=$245FF))or(($24600<=uc)and(uc<=$260FF))or(($26100<=uc)and(uc<=$275FF))or(($27600<=uc)and(uc<=$290FF))or(($29100<=uc)and(uc<=$2A6DF)) then result:='cjkb'
  //'cjkc'  ext c: 2A700-2B73F just additional mix ,
  else if (($2A700<=uc)and(uc<=$2B73F)) then result:='cjkc'
  //'cjkd' 2B740–2B81F small set
  else if (($2B740<=uc)and(uc<=$2B81F)) then result:='cjkd'
  //'cjke' 2B820–2CEAF big set 5,762 c of rare chars
  else if (($2B820<=uc)and(uc<=$2CEAF)) then result:='cjke'
  //'cjkf' 2CEB0–2EBEF big set 7,473 chars, rare symbols
  else if (($2CEB0<=uc)and(uc<=$2EBEF)) then result:='cjkf'
  //korean:
  //Hangul Syllables (AC00–D7A3)
  //Hangul Jamo (1100–11FF)
  //Hangul Compatibility Jamo (3130-318F)
  //Hangul Jamo Extended-A (A960-A97F)
  //Hangul Jamo Extended-B (D7B0-D7FF)
  else if (($AC00<=uc)and(uc<=$D7A3))or(($1100<=uc)and(uc<=$11FF))or(($3130<=uc)and(uc<=$318F))or(($A960<=uc)and(uc<=$A97F))or(($D7B0<=uc)and(uc<=$D7FF)) then result:='ko'
  else result:='other';
  //'en','ru'....

  //ISO 639-1 or ISO 639-2
  //I did a modification for chinese: traditional and simplified are different
  //let's set chineses , korean and japanise

  //Японский:
  //упрощенный:
  //Торадиционный:
  //Корейский:

  //'cjk': unicode areas main : 4E00-62FF, 6300-77FF, 7800-8CFF, 8D00-9FFF :main set, let's call it cjk
  //'cjka' ext a:  3400-4DBF
  //'cjkb' ext b: 20000-215FF, 21600-230FF, 23100-245FF, 24600-260FF, 26100-275FF, 27600-290FF, 29100-2A6DF. Kangxi Dictionary , formerly used to write Vietnamese. Not used now
  //'cjkc'  ext c: 2A700-2B73F just additional mix ,
  //'cjkd' 2B740–2B81F small set
  //'cjke' 2B820–2CEAF big set 5,762 c of rare chars
  //'cjkf' 2CEB0–2EBEF big set 7,473 chars, rare symbols

  //korean:
  //Hangul Syllables (AC00–D7A3)
  //Hangul Jamo (1100–11FF)
  //Hangul Compatibility Jamo (3130-318F)
  //Hangul Jamo Extended-A (A960-A97F)
  //Hangul Jamo Extended-B (D7B0-D7FF)



   {
  UnicodeCharLenToString(

  S: PUnicodeChar;

  Len: SizeInt

):AnsiString;

  StringToUnicodeChar(
  UnicodeCharLenToString(

  function StringToUnicodeChar(const Src : RawByteString;Dest : PUnicodeChar;DestSize : SizeInt) : PUnicodeChar;
  function UnicodeCharLenToString(S : PUnicodeChar;Len : SizeInt) : UnicodeString;
  procedure UnicodeCharLenToStrVar(Src : PUnicodeChar;Len : SizeInt;out Dest : UnicodeString);
  procedure UnicodeCharLenToStrVar(Src : PUnicodeChar;Len : SizeInt;out Dest : AnsiString);
  procedure UnicodeCharToStrVar(S : PUnicodeChar;out Dest : AnsiString);


  //http://www.unicode.org/Public/UNIDATA/Scripts.txt
  SetLength(hs,length(s));
  //function Utf8ToUnicode(Dest: PUnicodeChar; MaxDestChars: SizeUInt; Source: PChar; SourceBytes: SizeUInt): SizeUInt;




  i:=Utf8ToUnicode(PUnicodeChar(hs),length(hs)+1,pchar(s),length(s));

  function UTF8Decode(const s : RawByteString): UnicodeString;
    var
      i : SizeInt;
      hs : UnicodeString;
    begin
      result:='';
      if s='' then
        exit;
      SetLength(hs,length(s));
      i:=Utf8ToUnicode(PUnicodeChar(hs),length(hs)+1,pchar(s),length(s));
      if i>0 then
        begin
          SetLength(hs,i-1);
          result:=hs;
        end;
    end;


  setLength(ta, length(s));
  Move(s[1], ta[0], length(s));
  result:=inttostr(ta[0]);
 }
end;

function getCharVocSize(lng:string):integer;
begin




  case lng of
    'en':result:=26*2;
    'ru':result:=33*2;
    'cjk':result:=5000; //main cjk group; assume it is chinese (trad, simp) or japanse. Maybe an old korean, taiwan... etc
    'cjka':result:=3000; //ext a:  3400-4DBF  additional. small bonus for good words because we have main bonus in the basic cjk
    'cjkb':result:=5000; //traditional-spec, old words. Ok. let's add 5000 more
    'cjkc':result:=3000; //mix 5k set.
    'cjkd':result:=1000; //mix small set
    'cjke':result:=3000; // big one set of rare symbols
    'cjkf':result:=3000; // big one set of rare symbols
    'ko':result:=5000; //I did not find statistics
    //'ja':result:=2000; //specific japanise characters somewhere in cjk
  else
    result:=30*2;
  end;
end;


function getLangBasedVoc(s:string):integer;
var
  CurP, EndP: PChar;
  Len: Integer;
  c:string;
  lang,langsFound:string;
begin
  result:=0; langsFound:=' ';
  CurP := PChar(S);        // if S='' then PChar(S) returns a pointer to #0
  EndP := CurP + length(S);
  while CurP < EndP do
  begin
    Len := UTF8CharacterLength(CurP);
    SetLength(c, Len);
    Move(CurP^, c[1], Len);
    lang:=getLangByChar(c);//LazGetShortLanguageID(c);
    if pos(' '+lang+' ',langsFound)<1 then begin
      //new language!!!
      langsFound:=langsFound+lang+' ';
      result:=result+ getCharVocSize(lang);

      //for the cjk langs add cjk bonus one time
      if (pos('cjk',lang)=1) and (pos(' cjk ',langsFound)<1) then begin
        langsFound:=langsFound+'cjk'+' ';
        result:=result+ getCharVocSize('cjk');
      end;

    end;
    inc(CurP, Len);
  end;
end;

function ratePassword(password:string):double; //log10 rate
  var res:double;//this is the result

const Seq:string='1qazwsxedcrfvtgbyhnujm mjunhybgtvfrcdexswzaq1  ABCDEFGHIJKLMNOPQRSTUVWXYZ ZYXWVUTSRQPONMLKJIHGFEDCAB QWERTYUIOPASDFGHJKLZXCVBNM MNBVCXZLKJHGFDSAPOIUYTREWQ abcdefghijklmnopqrstuvwxyz zyxwvutsrqponmlkjihgfedcab qwertyuiopasdfghjklzxcvbnm mnbvcxzlkjhgfdsapoiuytrewq 1234567890 0987654321 ~!@#$%^&*()_+ +_)(*&^%$#@!~';

 type tpstat=record
        ansiSymFoundSet:set of ansichar;
        lowersFound,   // s[i]<>uppercase(s[i])
        uppersFound,   // s[i]<>lowercase(s[i])
        digitsFound,   // ['0'..'9']
        othersFound,   //less than 128 and not in ['0..9','a'..'Z','A'..'Z','.','?','!',',',' ','_','@','-']
        topsFound,     //char code more than 128
        bottomsFound,  //less than 128 in ['a'..'z','A'..'Z']
        symFound      //different symbols found (use symFoundSet)
        :integer;
      end;
 //for 3: pwd, odds, evens
 type twstat=record
   bipWordsFound,  //case insensetive
   killListWords,
   sequnces2Found,  //the same-symbol secuences more than 1
   sequnces3Found,  //the same-symbol secuences more than 2
   ascsFound,  //asc sequences more then 3 like abc or qwerty
   descsFound,  //decs sequences more then 3 like cbd or ytrewq
   digitsLinesFound,
   datesFound //вида <01..31><01..12> или <01..12><01..31> или четыре цифры, составляющие число от 1900 до 2030
   :integer;
 end;

 //Штраф за использование расстрельного списка зависит от длины последовательности
 //Последовательности расстельного списка ищем в Lower, upper, первая большая- остальные малые

 //Анализируем три варианта - пароль, только четные, только нечетные

 var pstat,pstatl,pstath:tpstat;
 var wstat,wstatl,wstath:twstat;

 function calcpstat(s:string):tpstat;
 var i:integer;
     u,l:string;
 begin
   fillchar(result,sizeof(result),#0);
   u:=UTF8uppercase(s);
   l:=UTF8lowercase(s);
   for i:=1 to length(s) do begin
     //symFoundSet:set of ansichar;
     //symFound      //different symbols found (use symFoundSet)
     //lowersFound,   // s[i]<>uppercase(s[i])
     //uppersFound,   // s[i]<>lowercase(s[i])
     //digitsFound,   // ['0'..'9']
     //othersFound,   //less than 128 and not in ['0..9','a'..'Z','A'..'Z','.','?','!',',',' ','_','@','-']
     //topsFound,     //char code more than 128
     //bottomsFound,  //less than 128 in ['a'..'z','A'..'Z']
     if not (s[i] in result.ansiSymFoundSet) then begin result.ansiSymFoundSet:=result.ansiSymFoundSet+[s[i]]; inc(result.symFound); end;
     if (s[i] <> u[i]) then inc(result.lowersFound);
     if (s[i] <> l[i]) then inc(result.uppersFound);
     if s[i] in ['0'..'9'] then inc(result.digitsFound);
     if (not (s[i] in ['0'..'9','a'..'z','A'..'Z','.','?','!',',',' ','_','@','-'])) and (ord(s[i])<128) then inc(result.othersFound);
     if ord(s[i])>=128 then inc(result.topsFound);
     if (ord(s[i])<128) and (s[i] in ['A'..'Z','a'..'z']) then inc(result.bottomsFound);
   end;
 end;

 var rt:double;


 function findLongest(sub,str:string;n:integer):integer;
 var i:integer;
     mpos,mlen:integer;
 begin
   //max 255 bytes
   i:=1;
   while ((i+n-1)<=length(sub)) and (pos(copy(sub,n,i),str)>0) do inc(i);
   result:=i-1;//min(255,i-1) ;
 end;

 function calcwstat(s:string;halfed:boolean):twstat;
 //changes rt itself!
 var i,j:integer;
     u,l:string;
     t,t1:string;
     n,m:integer;
     sou,founded:string;
     arr:array of integer;
     sa:arrayOfString;
 begin
   fillchar(result,sizeof(result),#0);
   u:=UTF8uppercase(s);
   l:=UTF8lowercase(s);

   //Ищем слова из расстрельного списка. Штрафуем на все, если оно в точном регистре (они все в low) и на половинну если регистры не бьются ни с ап, ни с лоу, или это половинка (if halfed)
     t:=l; sou:=s;
     for i:=0 to length(killList)-1 do
       while pos(UTF8lowercase(killList[i]),t)>0 do begin
         founded:=copy(sou,pos(UTF8lowercase(killList[i]),t),length(killList[i]));
         delete(sou,pos(UTF8lowercase(killList[i]),t),length(killList[i])); //the same to sou
         delete(t,pos(UTF8lowercase(killList[i]),t),length(killList[i]));
         inc(result.killListWords);
         //punish!!!
         if halfed or (founded<>killList[i]) then begin
           rt:=0.5;
           if halfed and (founded<>killList[i]) then rt:=0.25;
           rt:=rt*calcRate(58,length(killList[i])) - log10(length(killList));
           if rt>1 then begin
             lastRatePasswordPenalties.Append(localizzzeString('PasswordHelper.KillListWordHidden','hidden killlist word found:')+' -'+floattostr(0.1*round(10*rt))+' ("'+killList[i]+'")');
             res:=res-rt;
           end;
         end else begin
           rt:=calcRate(58,length(killList[i])) - log10(length(killList));
           if rt>1 then begin
             lastRatePasswordPenalties.Append(localizzzeString('PasswordHelper.KillListWord','killlist word found:')+' -'+floattostr(0.1*round(10*rt))+' ("'+killList[i]+'")');
             res:=res-rt;
           end;
         end;
       end;
   //bipWordsFound,  //case insensetive -> l
//   t:=u;               continue finding in the cutted string
   for i:=0 to length(bip0039english)-1 do
     while pos(lowercase(bip0039english[i]),t)>0 do begin
       delete(t,pos(lowercase(bip0039english[i]),t),length(bip0039english[i]));
       inc(result.bipWordsFound);
       //punish!!!
       rt:=calcRate(58,max(2,length(bip0039english[i])-2) )/4;
       lastRatePasswordPenalties.Append(localizzzeString('PasswordHelper.BipWordFound','BIP0039 word found, but not a BIP0039 pass: -'+floattostr(0.1*round(10*rt))+' ("'+bip0039english[i]+'")'));
       res:=res-rt;

     end;

   t:=s;
   if not halfed then
   for i:=0 to length(bip0039chinese)-1 do
     while pos(bip0039chinese[i],t)>0 do begin
       delete(t,pos(bip0039chinese[i],t),length(bip0039chinese[i]));
       inc(result.bipWordsFound);
       //punish!!!
       rt:=1.5;

       lastRatePasswordPenalties.Append(localizzzeString('PasswordHelper.BipWordFound','BIP0039 word found, but not a BIP0039 pass: -'+floattostr(0.1*round(10*rt))+' ("'+bip0039chinese[i]+'")'));
       res:=res-rt;
     end;



   //sequnces2Found,  //the same-symbol secuences more than 1
   //sequnces3Found,  //the same-symbol secuences more than 2
   n:=0; t:=s+' ';
   for i:=2 to length(t) do
     if s[i]=s[i-1] then inc(n) else if n<>0 then begin
       //sequense aaaa found. l=n
       if n=1 then inc(result.sequnces2Found) else inc(result.sequnces3Found);
       //punish!!!
       rt:=0.5*calcRate(58,n{+1}) - 1;
       if halfed then rt:=rt/2;
       if rt>1 then begin
         lastRatePasswordPenalties.Append(localizzzeString('PasswordHelper.LongOneSymbolSequence','long one-symbol sequense found: -'+floattostr(0.1*round(10*rt))+' ("'+stringofchar(s[i-1],n+1)+'")'));
         res:=res-rt;
       end;



       n:=0;
     end;

   //ascsFound,  //asc sequences more then 3 like abc or qwerty
   //descsFound,  //decs sequences more then 3 like cbd or ytrewq

   //тут нужно применить динамическое программирование.
   //построим два массива, длинной совпадающий строкой s. в них будем записывать номер позиции в s, в которой у нас удалось найти самую длинную последовательность, и ее длину (чисто для скорости).
   //при перезаписи

   //здесь же проверим самоцитирование - будем вышибать ДО этого символа включительно всё - и искать.

   //а может сделаем топорно? Для каждой строки найдем самую длинную последовательность ОТ нее, а потом будем выбивать их по убыванию...
   //а для самоцитирования - просто будем запрещать искать с этой строки и назад. так и рекурсивные повторы исключим заодно.
   //Решение, кстати, находит самые длинные строки, но не максимально замощает поисковую область. но это ок

   //1. ищем повторы в сек
   //t:=stringofchar(#0,length(s)); //рекорд длины в цели
   setLength(arr,length(s));
   fillchar(arr[0],length(s)*sizeof(integer),0);

   for i:=1 to length(s) do
     arr[i-1]:=findLongest(s,seq,i);
   //начиная с самого большого вычеркиваем "сломанные" в arr
   for i:=0 to length(arr)-2 do
     //если не ноль - убиваем вперед меньшие нашего. если убъём на это расстояние  - то оставляем не ноль, иначе пишем ноль.
     //если не убили - берем повтор тот, что есть сейчас (уменьшенный)
     if arr[i]>1 then
       for j:=i+1 to i+arr[i]-1 do
         if arr[i]>=arr[j]
           then arr[j]:=0
           else begin
             arr[i]:=j-i;
             break;
           end;
     //теперь в arr тольео длины живых повторов. выводим результат
     for i:=0 to length(arr)-2 do
       if arr[i]>2 then begin
         rt:=0.3*calcRate(58*2,arr[i]);
         if halfed then rt:=rt / 4;
         lastRatePasswordPenalties.Append(localizzzeString('PasswordHelper.Sequences','there are a standart sequense or key-walk: -'+floattostr(0.1*round(10*rt))+' ("'+copy(s,i-1,arr[i])+'")'));
         res:=res-rt;
       end;
  //self-repeats:-------------------------
  //t:=stringofchar(#0,length(s)); //рекорд длины в цели
  if not halfed then begin
    sa:=UTF8toAnsiCharArray(password);
    setLength(arr,length(sa));
    fillchar(arr[0],length(sa)*sizeof(integer),0);

    t:='';
    for i:=0 to length(sa)-1 do begin
      arr[i]:=findLongest(s,copy(s,length(t)+2,length(s)-length(t)-1),length(t)+1);
      t:=t+sa[i];
    end;
    //начиная с самого большого вычеркиваем "сломанные" в t
    for i:=0 to length(arr)-2 do
      //если не ноль - убиваем вперед меньшие нашего. если убъём на это расстояние  - то оставляем не ноль, иначе пишем ноль.
      //если не убили - берем повтор тот, что есть сейчас (уменьшенный)
      if arr[i]>1 then
        for j:=i+1 to i+arr[i]-1 do
          if arr[i]>=arr[j]
            then arr[j]:=0
            else begin
              arr[i]:=j-i;
              break;
            end;
      //теперь в arr тольео длины живых повторов. выводим результат
      t:='';
      for i:=0 to length(arr)-2 do begin
        if (arr[i]>(length(sa[i])+1)) {or ((arr[i]>1) and (length(sa[i])<2))}  then begin
          t1:=''; //rebuild repeat for complete char list
          for j:=i to length(sa)-1 do
            if length(t1)+length(sa[j]) > arr[i]
               then break
               else t1:=t1+sa[j];

          rt:=0.3*calcRate(58*2,{arr[i]}length(t1));
          if halfed then rt:=rt / 4;
          lastRatePasswordPenalties.Append(localizzzeString('PasswordHelper.selfRepeats','there are a self-repeat sequense : -'+floattostr(0.1*round(10*rt))+' ("'+t1{copy(s,length(t)+1,arr[i])}+'")'));
          res:=res-rt;
        end;
        t:=t+sa[i];
      end;
  end;

{
   t:=l+' '; sou:=s; n:=1; m:=1; j:=1;
   for i:=1 to length(s) do begin
     //looking for a sequeces
     //n is beginning in s, m is beginning in sec
     if s[i]<>sec[j] then begin//combobreakerh...
        //Возможно две ситуации.
       //1. это конец последовательности и звиздец
       //2. это конец последовательности, но где-то есть замена.
       t:=copy(s,n,i-n); //found seq
       if (i<>n) and (pos(t,seq)>0) then begin
          //Просто переходим на другую подстроку, которая пока есть
       end;


     end;

     if pos()

     if halfed then

   end;

 }
   //digitsLinesFound,
   //datesFound //вида <01..31><01..12> или <01..12><01..31> или четыре цифры, составляющие число от 1900 до 2030
   i:=4;
   while i<=length(s) do begin
     t:=copy(s,i-3,4);
     if not((t[1] in ['0'..'9']) and (t[2] in ['0'..'9']) and (t[3] in ['0'..'9']) and (t[4] in ['0'..'9'])) then begin inc(i); continue; end;

     if ((strtoint(copy(t,1,2)) in [1..12]) and (strtoint(copy(t,3,2)) in [1..31]))
        or
        ((strtoint(copy(t,3,2)) in [1..12]) and (strtoint(copy(t,1,2)) in [1..31]))
     then begin
       if halfed then rt:=1 else rt:=2;
       lastRatePasswordPenalties.Append(localizzzeString('PasswordHelper.DateFound','posible date found: -'+floattostr(0.1*round(10*rt))+' ("'+t+'")'));
       res:=res-rt;
       i:=i+3;
     end else if (strtoint(t)>=1900) and (strtoint(t)<=2020) then begin
       if halfed then rt:=1 else rt:=2;
       lastRatePasswordPenalties.Append(localizzzeString('PasswordHelper.YearFound','Possible year found: -'+floattostr(0.1*round(10*rt))+' ("'+t+'")'));
       res:=res-rt;
       i:=i+3;
     end;
     inc(i);

   end;


 end;

 var s:string;
     i,n:integer;
     mx,mn:integer;
     bipWordsFound:integer;
     so,se:string;
     b:boolean;
     sa:arrayOfString;
     ansis:ansistring;
begin
  res:=0;
  lastRatePasswordBonuses.Clear;
  lastRatePasswordPenalties.Clear;
  sa:=UTF8toAnsiCharArray(password);
  //rate is log of the possible passwords count

  //bip pass:follow BIP
  ansis:=bip39tobytes(trim(password));
  if ansis<>'' then begin
    bipWordsFound:=((length(ansis)*8) div 11);
    result:=calcRate(length(bip0039english),bipWordsFound);
    exit;
  end;

  //is it BIP39 pwd? only spaces and bip39 words here
  bipWordsFound:=0;
  s:=' '+UTF8uppercase(password)+' ';
  for i:=0 to length(bip0039english)-1 do
    while pos(' '+uppercase(bip0039english[i])+' ',s)>0 do begin
       delete(s,pos(' '+uppercase(bip0039english[i])+' ',s),length(' '+bip0039english[i]));
       inc(bipWordsFound);
    end;
  s:=trim(s);
  if s='' then begin
    //BIP-pwd
     result:=calcRate(length(bip0039english),bipWordsFound);  //bipWordsFound+log10(power(length(bip0039english)/10,bipWordsFound));   // log10(power(length(bip0039english),bipWordsFound)); =  length + log10(power(b/10,length))
     exit;
  end;


  //!!!!!!!!!!
  s:=password;
  i:=getLangBasedVoc(s);//calculate possible size of the vocabulary

  n:=58;
  if i>128 then n:=100;
  if i>1000 then n:=150;
  //n:= //Choises in a byte; if i>1000 -> let's choose 7 bit

  res:=calcRate(n,SymbolCount(s)); //length(password)+log10(power(5.8,length(password))); //as a zero point assume that code58-style charset is unsing   r = log10(power(58,length(password))) = length + log10(power(b/10,length))


  //if more than 2 CHINESE or other big-set symbols are used then calc base following the symbols used
  if i>128 then //this is only notyfication
    if i>1000 then
      begin
        rt:=res - calcRate(58,length(sa));
        lastRatePasswordBonuses.Append(localizzzeString('PasswordHelper.BigUnicodeBonus','Used international characters with a large set (Chinese characters, etc.):')+' +'+floattostr(0.1*round(10*rt))+'');
      end else begin
        rt:=res - calcRate(58,length(sa));
        lastRatePasswordBonuses.Append(localizzzeString('PasswordHelper.UnicodeBonus','Both international and ascii characters are used:')+' +'+floattostr(0.1*round(10*rt))+'');
      end;


  //calc initial rate
  mx:=32;
  mn:=255;
  s:=password;
  for i:=1 to length(s) do begin
    mx:=max(mx,ord(s[i]));
    if s[i] in ['a'..'z','A'..'Z'] then mn:=min(mn,ord(s[i]));
  end;
  //the base charset was 58b. if you use both unicode and non-unicode we have 2 bit * len bonus
{ This is taken into account when calculating res
  if (mn<=128) and (mx>128) then begin
    rt:=log10(2*length(password));
    //inttostr(floattostr(0.1*round(10*rt))))

    lastRatePasswordBonuses.Append(localizzzeString('PasswordHelper.UnicodeBonus','Both international and ascii characters are used:')+' +'+floattostr(0.1*round(10*rt))+'');
    res:=res+rt;
  end;
  }
  //======================================================================
  //making odd and even substr
  s:=password;
  so:='';
  se:='';
  for i:=0 to length(sa)-1 do
    if i mod 2 = 0 then so:=so+sa[i] else se:=se+sa[i];
  //var pstat,pstatl,pstath:tpstat;
  //function calcpstat(s:ansistring):tpstat;
   pstat:=calcpstat(s);
   pstatl:=calcpstat(se);
   pstath:=calcpstat(so);
   //Calc bonuses
   wstat:=calcwstat(s,false);
   wstatl:=calcwstat(se,true);
   wstath:=calcwstat(so,true);


   //lowersFound,   // s[i]<>uppercase(s[i])
   //uppersFound,   // s[i]<>lowercase(s[i])
   //digitsFound,   // ['0'..'9']
   //othersFound,   //less than 128 and not in ['0..9','a'..'Z','A'..'Z','.','?','!',',',' ','_','@','-']
   //topsFound,     //char code more than 128
   //bottomsFound,  //less than 128 in ['a'..'z','A'..'Z']
   //symFound

   //Награда за разнообразие.
   //1.нет букв- примерно наказать. есть только маленькие или только большие буквы - наказать за регистр.
   //2. нет цифр - наказать что нет цифр
   //3. есть othersFound - молодец, бонус 10 % и если в h и l - 15%

   //1
   if (pstat.lowersFound=0) and (pstat.uppersFound=0) then begin
     res:=res-abs(0.4*res);
     lastRatePasswordPenalties.Append(localizzzeString('PasswordHelper.NoLetters','You did not use any letters: punishment 40%.'));
   end else if (pstat.lowersFound=0) or (pstat.uppersFound=0) then begin
     rt:=0.15*calcRate(58,max(pstat.lowersFound+pstat.uppersFound,2));
     lastRatePasswordPenalties.Append(localizzzeString('PasswordHelper.NoLetters','You used one letter case:')+' -'+floattostr(0.1*round(10*rt)));
     res:=res-rt;
   end;

  //2
  if pstat.digitsFound=0 then begin
    res:=res - abs(res*0.1);
    lastRatePasswordPenalties.Append(localizzzeString('PasswordHelper.NoDigits','You did not use any digits: punishment 10%.'));
  end else if (length(password)>2) and (length(password)<>pstat.digitsFound) then begin
    //CCCCCCNNNN punishment; XXXXXX1
    b:=false;
    for i:=1 to length(password)-1 do //NC
      if ((password[i] in ['0'..'9'])) and  (not (password[i+1] in ['0'..'9'])) then begin b:=true; break; end;
    if not b then begin
      rt:=0.8*calcRate(58,pstat.digitsFound);
      lastRatePasswordPenalties.Append(localizzzeString('PasswordHelper.DigitsEnd','Your password ends in numbers, but does not contain numbers inside:')+' -'+floattostr(0.1*round(10*rt)));
      res:=res-rt;
    end;
    if password[length(password)]='1' then begin
       //XXXXXX1 is BAD!
      if b then rt:=0.9 else rt:=0.1;
      lastRatePasswordPenalties.Append(localizzzeString('PasswordHelper.End1','Your password ends in `1`:')+' -'+floattostr(0.1*round(10*rt)));
      res:=res-rt;

    end;
  end;
  //3
  if pstat.othersFound>0 then begin
    //58 -> 96 kinds: + 38 kinds ~
    //if pstatl.othersFound*pstath.othersFound>0 then rt:=log10(5*length(password)) else rt:=log10(4*length(password)); // rt:=0.15*res else rt:=0.1*res;

    if pstatl.othersFound*pstath.othersFound>0 then rt:=calcRate(2,length(password)) else rt:=calcRate(2,(2*length(password)) div 3);
    lastRatePasswordBonuses.Append(localizzzeString('PasswordHelper.othersFound','You have used special symbols:')+' :+'+floattostr(0.1*round(10*rt)));
    res:=res+rt;
  end;

  //111122221111222233333маЫ5ddggg34dfffffffdfsdf@@@3434rfdfdsdfds3  -переминусовка

  //-----------------пенальти за диверсификацию symFound
  if (pstat.symFound<10) and (pstat.symFound/length(password)<0.5 ) then begin
    rt:= abs((0.5-(pstat.symFound/length(password)))  * res);
    lastRatePasswordPenalties.Append(localizzzeString('PasswordHelper.DifferentChars','You have used too many the same symbols:')+' :-'+floattostr(0.1*round(10*rt)));
    res:=res-rt;
  end;

  //long password bonus: 2 bit per symbol- stage one, before check for negative
  if (length(password)>15) and (result<0) then begin
    rt:= calcRate(2,length(password)+ (length(password)-15)*1); //for message only!
    lastRatePasswordBonuses.Append(localizzzeString('PasswordHelper.LongPasswordBonus','Your password quite long:')+' +'+floattostr(0.1*round(10*rt))+'');

    rt:= calcRate(2,(length(password)-15)*1);
    result:=result+rt;
  end;

  result:=max(0,res);

  rt:= calcRate(2,length(password));
  if (length(password)>0) and (result<rt) then begin //stage 2
    rt:= calcRate(2,length(password));
    result:=result+rt;
  end;


  //var wstat,wstatl,wstath:twstat;




end;

initialization
  lastRatePasswordBonuses:=tStringList.Create;
  lastRatePasswordPenalties:=tStringList.Create;
  RndGen:=tRndGen.create;
finalization
  lastRatePasswordBonuses.free;
  lastRatePasswordPenalties.free;
  RndGen.free;
end.

