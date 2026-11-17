<?php

// Installed by laravel-software-factory. These enforce the rules in AGENTS.md.
// The gate fails if tests/Architecture is empty, so extend this file rather than deleting it.

arch()->preset()->php();
arch()->preset()->security();
arch()->preset()->laravel();

arch('controllers do not run queries through the DB facade')
    ->expect('App\Http\Controllers')
    ->not->toUse('Illuminate\Support\Facades\DB');

// Forces input through Form Requests and $request->validated(). Reading the raw
// Request in controllers led to unvalidated filters and 500s on array input.
arch('controllers take Form Requests, not the raw Request')
    ->expect('App\Http\Controllers')
    ->not->toUse('Illuminate\Http\Request');

arch('models do not depend on the HTTP layer')
    ->expect('App\Models')
    ->not->toUse('App\Http');

arch('actions do not depend on the HTTP layer')
    ->expect('App\Actions')
    ->not->toUse(['App\Http', 'Illuminate\Http\Request']);
