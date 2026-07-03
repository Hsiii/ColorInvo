import nextPlugin from '@next/eslint-plugin-next';
import { completeConfigBase } from 'eslint-config-complete';

export default [
    ...completeConfigBase,

    {
        ignores: ['.next/**', 'dist/**', 'next-env.d.ts', 'node_modules/**'],
    },

    {
        plugins: {
            '@next/next': nextPlugin,
        },
        rules: {
            ...nextPlugin.configs.recommended.rules,
            ...nextPlugin.configs['core-web-vitals'].rules,
            '@stylistic/quotes': [
                'error',
                'single',
                {
                    avoidEscape: true,
                },
            ],
            'import-x/no-unassigned-import': [
                'error',
                {
                    allow: ['**/*.css'],
                },
            ],
        },
    },

    {
        files: ['src/app/**/*.ts', 'src/app/**/*.tsx'],
        rules: {
            'complete/require-ascii': 'off',
        },
    },

    {
        files: ['src/app/**/*.tsx'],
        rules: {
            'complete/no-mutable-return': 'off',
            '@typescript-eslint/explicit-module-boundary-types': 'off',
            'n/file-extension-in-import': 'off',
            'import-x/no-default-export': 'off',
        },
    },

    {
        files: ['src/app/robots.ts', 'src/app/sitemap.ts'],
        rules: {
            'import-x/no-default-export': 'off',
            'n/file-extension-in-import': 'off',
        },
    },
];
