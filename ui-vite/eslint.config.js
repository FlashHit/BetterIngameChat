import js from '@eslint/js';
import globals from 'globals';
import reactHooks from 'eslint-plugin-react-hooks';
import reactRefresh from 'eslint-plugin-react-refresh';
import tseslint from 'typescript-eslint';
import { defineConfig, globalIgnores } from 'eslint/config';
import eslintPluginReact from 'eslint-plugin-react';
import prettierPlugin from 'eslint-plugin-prettier';
import unusedImports from 'eslint-plugin-unused-imports';
import sompleImportSort from 'eslint-plugin-simple-import-sort';

export default defineConfig([
    globalIgnores(['dist']),
    {
        files: ['**/*.{ts,tsx}'],
        extends: [
            js.configs.recommended,
            tseslint.configs.recommended,
            reactHooks.configs['recommended-latest'],
            reactRefresh.configs.vite,
        ],
        languageOptions: {
            ecmaVersion: 2020,
            globals: globals.browser,
        },
        plugins: {
            react: eslintPluginReact,
            prettier: prettierPlugin,
            'unused-imports': unusedImports,
            'simple-import-sort': sompleImportSort,
        },
        rules: {
            ...reactHooks.configs.recommended.rules,
            'react-refresh/only-export-components': ['warn', { allowConstantExport: true }],
            'react-hooks/exhaustive-deps': 0,
            'react/jsx-no-leaked-render': ['error'],
            'react/jsx-boolean-value': ['error'],
            '@typescript-eslint/no-explicit-any': ['off'],
            '@typescript-eslint/no-unused-vars': ['warn', { argsIgnorePattern: '^_', varsIgnorePattern: '^_' }],

            // Automatically remove unused imports
            'unused-imports/no-unused-imports': 'error',

            // Sort imports
            'simple-import-sort/imports': 'error',
            'simple-import-sort/exports': 'error',

            'no-case-declarations': 'off',
        },
    },
]);
