// JSEmitter
// =========
// 
// This module is designed to provide a sane typesafe way to build Javascript strings
// by composing emitters. It has just enough coverage to compile Chitchat, and doesn't
// support most operators
var assert = require('assert');

var GLOBAL = this;
var _toString = Object.prototype.toString;

var classString = exports.classString = function (obj) {
    switch (obj) {
        case GLOBAL:
            return 'Global';

        case (void 0):
            return 'Undefined';

        case null:
            return 'Null';

        default:
            return _toString.call(obj).slice(8, -1);
    }
};

var format = exports.format = function (template) {
    var values = Array.prototype.slice.call(arguments, 1);

    return template.replace(/\$(\d+)/g, function (_, n) {
        assert.equal(classString(values[n]), 'String');
        return values[n];
    }); 
};

// JSEmitter
// =========
// 
// JSEmitter (and its subclasses) allow us to build a Javascript AST
// from typed and inspectable objects instead of by concatenating strings
// in an ad-hoc fashion.
var JSEmitter = function () {};
exports.JSEmitter = JSEmitter;

// But there are compromises, when you want to emit 'just' 
// a javascript string, you can wrap in the JSEmitter type 
// using the static method just
JSEmitter.just = function (str) {
    var emitter = new JSEmitter();
    emitter.compileAsExpression = function () {
        return str;
    };

    return emitter;
};

JSEmitter.justExpression = function (str) {
    var emitter = new JSEmitter();

    emitter.compileAsStatement = function () {
        throw new TypeError('No Expressions syntax defined');
    };

    emitter.compileAsExpression = function () {
        return str;
    };

    return emitter;
};

// If you want to include an ad-hoc javascript string
// that is NOT a valid expression, you can use the static method
// 'justStatement'
JSEmitter.justStatement = function (str) {
    var emitter = new JSEmitter();

    emitter.compileAsStatement = function () {
        return str;
    };

    return emitter;
};

JSEmitter.compileAsExpression = function (obj) {
    assert.ok(obj instanceof JSEmitter);
    return obj.compileAsExpression();
};

JSEmitter.compileAsStatement = function (obj) {
    assert.ok(obj instanceof JSEmitter, obj + ': is a JSEmitter');
    return obj.compileAsStatement();
};

JSEmitter.compileAsStatements = function (arr) {
    return arr.map(function (emitter) {
        return JSEmitter.compileAsStatement(emitter);
    }).join('');
};

JSEmitter.compileBlock = function (exprs) {
    // compile every item of exprs except the last as a statement
    // compile the last one as a return statement
    return exprs.slice(1)
        .map(JSEmitter.compileAsStatement)
        .concat(JSEmitter.compileAsReturnStatement(exprs[exprs.length - 1]))
        .join('\n');	
}

JSEmitter.prototype.compileAsExpression = function() {
    throw new Error('Not Implemented');
};

JSEmitter.prototype.compileAsStatement = function () {
    return this.compileAsExpression() + ';\n';
};

JSEmitter.prototype.compileAsReturnStatement = function () {
    return 'return ' + this.compileAsExpression() + ';\n';
};

JSEmitter.prototype.compileAsAssignment = function (place) {
    return format('{0} = {1}',
                  JSEmitter.compileAsPlace(place),
                  this.compileAsExpression());
};

JSEmitter.prototype.compileAsPlace = function () {
    throw new TypeError('Cannot compile as a place');
};

JSEmitter.prototype.toString = function () {
    return 'JSEmitter';
};
var JSSequenceEmitter = function (emitters) {
    emitters.forEach(function (item) {
        if (!(item instanceof JSEmitter)) {
            throw new TypeError(item + ' is not a JSEmitter');
        }
    });
    this.emitters = emitters;
};

exports.JSSequenceEmitter = JSSequenceEmitter;

JSSequenceEmitter.prototype = new JSEmitter();

JSSequenceEmitter.prototype.compileAsStatement = function () {
    return this.emitters.map(JSEmitter.compileAsStatement).join('\n');
};

var JSNumberEmitter = function (value) {
    this.value = value;
    assert.equal(typeof value, 'number');
};

exports.JSNumberEmitter = JSNumberEmitter;

JSNumberEmitter.prototype = new JSEmitter();

JSNumberEmitter.prototype.compileAsExpression = function () {
    return JSON.stringify(this.value);   
};

var JSStringEmitter = function (value) {
    this.value = value;
    assert.equal(typeof value, 'string');
};

exports.JSStringEmitter = JSStringEmitter;

JSStringEmitter.prototype = new JSEmitter();

JSStringEmitter.prototype.compileAsExpression = function () {
    return JSON.stringify(this.value);   
};

var JSAssignmentEmitter = function (place, value) {
    assert.ok(place.compileAsPlace != JSEmitter.prototype.compileAsPlace,
              'place must be able to compile as a place');
    this.place = place;
    this.value = value;
}; 

exports.JSAssignmentEmitter = JSAssignmentEmitter;

JSAssignmentEmitter.prototype = new JSEmitter();

JSAssignmentEmitter.prototype.compileAsExpression = function () {
    this.value.compileAsAssignment(this.place);
};

var JSSymbolEmitter = function (value) {
    this.value = value;
    this.validate();
};

exports.JSSymbolEmitter = JSSymbolEmitter;

JSSymbolEmitter.prototype = new JSEmitter();

JSSymbolEmitter.prototype.compileAsExpression = function () {
    return this.value;
};

JSSymbolEmitter.prototype.compileAsPlace = JSSymbolEmitter.prototype.compileAsPlace;

JSSymbolEmitter.prototype.validate = function () {
    var msg = ['"', this.value, '" should be a valid javascript Identifier'].join('');
    assert.ok(JSSymbolEmitter.reserved.indexOf(this.value) == -1, msg);
    assert.ok(JSSymbolEmitter.keywords.indexOf(this.value) == -1, msg);
    assert.ok(/^[a-z_\$][a-z0-9_\$]*$/i.test(this.value), msg);
};

JSSymbolEmitter.compile = function (sym) {
    assert.ok(sym instanceof JSSymbolEmitter);
    return sym.compileAsExpression();
};

JSSymbolEmitter.keywords = [
    'this', 'null', 'undefined', 'true', 'false'
];

JSSymbolEmitter.reserved = [
    'break', 'case', 'catch', 'continue', 'debugger', 
    'default', 'delete', 'do', 'else', 'finally', 'for', 
    'function', 'if', 'in', 'instanceof', 'new', 'return', 
    'switch', 'this', 'throw', 'try', 'typeof', 'var', 'void', 
    'while', 'with', 'class', 'enum', 'extends', 'super', 
    'const', 'export', 'import', 'null', 'true', 'false'
];   

var JSAccessorEmitter = function (root, key) {
    this.root = root;
    this.key = key
    assert.ok(this.root instanceof JSEmitter);
    assert.ok(this.key instanceof JSEmitter);
};

exports.JSAccessorEmitter = JSAccessorEmitter;

JSAccessorEmitter.prototype = new JSEmitter();

JSAccessorEmitter.prototype.compileAsExpression = function () {
    return format('$0[$1]',
                  JSEmitter.compileAsExpression(this.root),
                  JSEmitter.compileAsExpression(this.key));
};

JSAccessorEmitter.prototype.compileAsPlace = JSAccessorEmitter.prototype.compileAsPlace;

var JSFunctionEmitter = function (args, body, result) {
    this.args = args;
    this.body = body;
    this.result = result;
};

exports.JSFunctionEmitter = JSFunctionEmitter;

JSFunctionEmitter.prototype = new JSEmitter();

JSFunctionEmitter.prototype.compileAsExpression = function () {
    var _args = this.args.map(JSSymbolEmitter.compile).join(', '),
    _body = JSEmitter.compileAsStatements(this.body),
    _result = this.result ? this.result.compileAsReturnStatement() : '';

    return format('(function ($0) {$1$2})',
                  _args, _body, _result);
};

var JSFunctionCallEmitter = function (fun, args) {
    this.fun = fun;
    this.args = args;
};

exports.JSFunctionCallEmitter = JSFunctionCallEmitter;

JSFunctionCallEmitter.prototype = new JSEmitter();

JSFunctionCallEmitter.prototype.compileAsExpression = function () {
    return format('$0($1)', 
                  this.fun.compileAsExpression(), 
                  this.args.map(JSEmitter.compileAsExpression).join(', '));
};

var JSMethodCallEmitter = function (obj, methodName, args) {
    this.obj = obj;
    this.methodName = methodName;
    this.args = args;

    assert.ok(this.obj instanceof JSEmitter);
    assert.ok(this.methodName instanceof JSEmitter);
    this.args.forEach(function (arg) {
        assert.ok(arg instanceof JSEmitter, arg + ':  is not a JSEmitter');
    });
};

exports.JSMethodCallEmitter = JSMethodCallEmitter;

JSMethodCallEmitter.prototype = new JSEmitter();

JSMethodCallEmitter.prototype.compileAsExpression = function () {
    return format('$0[$1]($2)',
                  this.obj.compileAsExpression(),
                  this.methodName.compileAsExpression(),
                  this.args.map(JSEmitter.compileAsExpression).join(', '));
};

var JSIfEmitter = function (test, trueBranch, falseBranch) {
    this.test = test;
    this.trueBranch = trueBranch;
    this.falseBranch = falseBranch;
};

exports.JSIfEmitter = JSIfEmitter;

JSIfEmitter.prototype = new JSEmitter();

JSIfEmitter.prototype.compileAsExpression = function () {
    var falseBranch = this.falseBranch || JSKeywordEmitter.NULL; 

    return format('($0?$1:$2)', 
                  this.test.compileAsExpression(),
                  this.trueBranch.compileAsExpression(),
                  falseBranch.compileAsExpression());
};

JSIfEmitter.prototype.compileAsStatement = function () {
    if (this.falseBranch == null) {
        return format('if ($0) {\n$1\n}',
                      this.test.compileAsExpression(),
                      this.trueBranch.compileAsStatement());
    } else {
        return format('if ($0) {\n$1\n} else {\n$2\n}',
                      this.test.compileAsExpression(),
                      this.trueBranch.compileAsStatement(),
                      this.falseBranch.compileAsStatement());
    }
};

var JSKeywordEmitter = function (keyword) {
    // TODO: should this be called reserved identifier?
    this.keyword = keyword;
};

exports.JSKeywordEmitter = JSKeywordEmitter;
JSKeywordEmitter.prototype = new JSEmitter();
JSKeywordEmitter.prototype.compileAsExpression = function () {
    return this.keyword;
};

JSKeywordEmitter.TRUE = new JSKeywordEmitter('true');
JSKeywordEmitter.FALSE = new JSKeywordEmitter('false');
JSKeywordEmitter.NULL = new JSKeywordEmitter('null');
JSKeywordEmitter.UNDEFINED = new JSKeywordEmitter('undefined');
JSKeywordEmitter.THIS = new JSKeywordEmitter('this');
JSKeywordEmitter.ARGUMENTS = new JSKeywordEmitter('arguments');

var JSVariableDeclaration = function (symbols) {
    this.symbols = symbols;
};

exports.JSVariableDeclaration = JSVariableDeclaration;

JSVariableDeclaration.prototype = new JSEmitter();

JSVariableDeclaration.prototype.compileAsExpression = function () {
    throw new TypeError('Variable Declarations cannot be compiled as an expression');
};

JSVariableDeclaration.prototype.compileAsStatement = function () {
    if (this.symbols.length === 0) return '';

    return format('var $0;', this.symbols.map(JSSymbolEmitter.compile).join(', '));
};

var JSDictionaryEmitter = function (dict) {
    // dict should be a dictionary of JSEmitters
    this.dict = dict;
};

exports.JSDictionaryEmitter = JSDictionaryEmitter;

JSDictionaryEmitter.prototype = new JSEmitter();

JSDictionaryEmitter.prototype.compileAsExpression = function () {
    var pairs = [], key, value;
    for (key in this.dict) if ({}.hasOwnProperty.call(this.dict, key)) {
        value = this.dict[key];

        pairs.push(format('$0:$1', JSON.stringify(key), value.compileAsExpression()));
    }

    return format('{$0}', pairs.join(', '));
};

var JSArrayEmitter = function (array) {
    this.array = array;
}

exports.JSArrayEmitter = JSArrayEmitter;

JSArrayEmitter.prototype = new JSEmitter();

JSArrayEmitter.prototype.compileAsExpression = function() {
    return format('[$0]', this.array.map(JSEmitter.compileAsExpression).join(', '));
};

var JSInfixEmitter = function () {};

exports.JSInfixEmitter = JSInfixEmitter;

JSInfixEmitter.prototype = new JSEmitter();

JSInfixEmitter.prototype.compileAsExpression = function () {
    assert.equal(classString(this.operator), 'String');
    return '(' + this.operands.map(JSEmitter.compileAsExpression).join(this.operator) + ')';
};

JSInfixEmitter.newInfix = function (operator) {
    var Constructor = function (operands) {
        this.operands = operands;
    };

    Constructor.prototype = new JSInfixEmitter();
    Constructor.prototype.operator = operator;

    return Constructor;
};

// These are necessary because they are shortcutting operators
var JSAndEmitter = JSInfixEmitter.newInfix('&&');
var JSOrEmitter = JSInfixEmitter.newInfix('||');

exports.JSAndEmitter = JSAndEmitter;
exports.JSOrEmitter = JSOrEmitter;

var maybeArgs = JSEmitter.justExpression('typeof arguments != "undefined" ? arguments : []');
// IIFE - Immediately Invoked Function Expression
// Can be used to create a new scope for local variables
// This version of the IIFE retains all other context of its host function 
// i.e. 'this' and 'arguments'
var JSIIFEEmitter = function (statements, result) {
    var fn = new JSFunctionEmitter([], statements, result);
    this.stx = new JSMethodCallEmitter(fn, new JSStringEmitter('apply'), [JSKeywordEmitter.THIS, maybeArgs]);
};

exports.JSIIFEEmitter = JSIIFEEmitter;

JSIIFEEmitter.prototype = new JSEmitter();

JSIIFEEmitter.prototype.compileAsExpression = function () {
    return this.stx.compileAsExpression();
};

var TryCatchEmitter = function (exprs, errSymbol, catchExprs) {
    this.exprs = exprs;
    this.errSymbol = errSymbol;
    this.catchExprs = catchExprs;
};

exports.TryCatchEmitter = TryCatchEmitter;

TryCatchEmitter.prototype = new JSEmitter();

TryCatchEmitter.prototype.compileAsStatement = function () {
    return format('try {$0} catch ($1) {$2}',
                  this.exprs.map(JSEmitter.compileAsStatement).join(''),
                  JSSymbolEmitter.compile(this.errSymbol),
                  this.catchexprs.map(JSEmitter.compileAsStatement).join(''));
};

TryCatchEmitter.prototype.compileAsReturnStatement = function () {
    return this.asReturnStatement().compileAsStatement();
};

TryCatchEmitter.prototype.compileAsExpression = function () {
    return new JSIIFEEmitter(this.asReturnStatement(), null).compileAsExpression();
};

TryCatchEmitter.prototype.asReturnStatement = function () {
    var tryBlock = JSEmitter.compileBlock(this.exprs),
        catchBlock = JSEmitter.compileBlock(this.catchExprs);

    return JSEmitter.justStatement('try {$0$1} catch ($2) {$3$4}',
                                   tryBlock,
                                   JSSymbolEmitter.compile(this.errSymbol),
                                   catchBlock);
};


var TryCatchFinallyEmitter = function (exprs, errSymbol, catchExprs, finallyExprs) {
    this.exprs = exprs;
    this.errSymbol = errSymbol;
    this.catchExprs = catchExprs;
    this.finallyExprs = finallyExprs;
};

exports.TryCatchFinallyEmitter = TryCatchFinallyEmitter;

TryCatchFinallyEmitter.prototype = new JSEmitter();

TryCatchFinallyEmitter.prototype.template = 'try {$0} catch ($1) {$2} finally {$3}';

TryCatchFinallyEmitter.prototype.compileAsStatement = function () {
    return format(this.template,
                  JSEmitter.compileAsStatements(this.exprs),
                  JSSymbolEmitter.compile(this.errSymbol),
                  JSEmitter.compileAsStatements(this.catchExprs),
                  JSEmitter.compileAsStatements(this.finallyExprs));
};

TryCatchFinallyEmitter.prototype.compileAsReturnStatement = function () {
    return format(this.template,
                  JSEmitter.compileAsStatements(this.exprs),
                  JSSymbolEmitter.compile(this.errSymbol),
                  JSEmitter.compileAsStatements(this.catchExprs),
                  JSEmitter.compileBlock(this.finallyExprs));
};

TryCatchFinallyEmitter.prototype.compileAsExpression = function () {
    var body = JSEmitter.justStatement(this.compileAsStatement());
    return new JSIIFEEmitter(body, null).compileAsExpression();
};